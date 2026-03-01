/*
 ***********************************************************************************************************
 * @file
 * fx_tg__xvalue__audit.sql
 *
 * Trigger function - log changes in x_value to custom audit table (AFTER update).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__xvalue__audit;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__xvalue__audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _sid1 TEXT;
    _first_pdi INT;
    _last_pdi INT;
    _now TIMESTAMPTZ := NOW();

BEGIN
    -- Just like Highlander, there can be only one...
    _sid1 := (SELECT sid1 FROM ce_warehouse.c__series WHERE pk_series = COALESCE(NEW.fk_pk_series, OLD.fk_pk_series));

    IF TG_OP = 'INSERT' THEN

        /***************************************************************************
         * INSERT
         ***************************************************************************/

        INSERT INTO ce_warehouse.a_xvalue (
            fk_pk_series, pdi, itype, isource, value, realised, audit_type
        )
        VALUES (
            NEW.fk_pk_series, NEW.pdi, NEW.itype, NEW.isource, NEW.value, FALSE, 'I'
        );

        -- upsert x_series_meta
        INSERT INTO ce_warehouse.x__series_meta (
            fk_pk_series, ifreq, itype, sid1, first_pdi, last_pdi, has_values, ts_new_values
        )
        VALUES (
            NEW.fk_pk_series, NEW.ifreq, NEW.itype, _sid1, NEW.pdi, NEW.pdi, TRUE, _now
        )
        ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET first_pdi = LEAST(COALESCE(x_series_meta.first_pdi, EXCLUDED.first_pdi), EXCLUDED.first_pdi),
                    last_pdi  = GREATEST(COALESCE(x_series_meta.last_pdi, EXCLUDED.last_pdi), EXCLUDED.last_pdi),
                    has_values = EXCLUDED.has_values,
                    ts_new_values = EXCLUDED.ts_new_values;

    ELSEIF TG_OP = 'UPDATE' THEN

        /***************************************************************************
         * UPDATE
         ***************************************************************************/

        IF (OLD.value IS DISTINCT FROM NEW.value)
            OR (OLD.itype IS DISTINCT FROM NEW.itype)
            OR (OLD.isource IS DISTINCT FROM NEW.isource) THEN

            INSERT INTO ce_warehouse.a_xvalue (
                fk_pk_series, pdi, itype, isource, value, new_value, realised, audit_type
            )
            VALUES (
                OLD.fk_pk_series, OLD.pdi, OLD.itype, OLD.isource, OLD.value, NEW.value,
                (OLD.itype = 2 AND NEW.itype = 1), 'U'
            );

            -- update x_series_meta
            INSERT INTO ce_warehouse.x__series_meta (
                fk_pk_series, ifreq, itype, sid1, has_values, ts_updated_values
            )
            VALUES (
                OLD.fk_pk_series, OLD.ifreq, OLD.itype, _sid1, TRUE, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
                DO UPDATE
                    SET sid1 = EXCLUDED.sid1,
                        has_values = EXCLUDED.has_values,
                        ts_updated_values = EXCLUDED.ts_updated_values;
        END IF;

    ELSEIF TG_OP = 'DELETE' THEN

        /***************************************************************************
         * DELETE
         ***************************************************************************/

        INSERT INTO ce_warehouse.a_xvalue(fk_pk_series, pdi, itype, isource, value, realised, audit_type)
        VALUES (
            OLD.fk_pk_series, OLD.pdi, OLD.itype, OLD.isource, OLD.value, FALSE, 'D'
        );

        -- recompute bounds
        SELECT MIN(pdi), MAX(pdi) INTO _first_pdi, _last_pdi
        FROM ce_warehouse.x__value
        WHERE fk_pk_series = OLD.fk_pk_series
        AND ifreq = OLD.ifreq
        AND itype = OLD.itype;

        INSERT INTO ce_warehouse.x__series_meta(fk_pk_series, ifreq, itype, first_pdi, last_pdi, has_values, ts_updated_values)
        VALUES (
            OLD.fk_pk_series, OLD.ifreq, OLD.itype, _first_pdi, _last_pdi, (_first_pdi IS NOT NULL), _now
        )
        ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET first_pdi = EXCLUDED.first_pdi,
                    last_pdi  = EXCLUDED.last_pdi,
                    has_values = EXCLUDED.has_values,
                    ts_updated_values = EXCLUDED.ts_updated_values;

    END IF;

    -- No need to return a record since this is an AFTER trigger
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__xvalue__audit
    IS 'Trigger function - log changes in x_value to custom audit table (AFTER update)';
