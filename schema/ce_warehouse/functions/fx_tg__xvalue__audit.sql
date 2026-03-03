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
    -- Just like Highlander, there can be only one...
    _sid1 TEXT := (SELECT sid1 FROM ce_warehouse.c__series WHERE pk_series = COALESCE(NEW.fk_pk_series, OLD.fk_pk_series));

    _first_pdi INT;
    _last_pdi INT;
    _now TIMESTAMPTZ := NOW();

BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    IF TG_OP = 'INSERT' THEN

        /***************************************************************************
         * INSERT
         ***************************************************************************/

        INSERT INTO ce_warehouse.a_xvalue (
            fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, realised, audit_type, audit_user
        )
        VALUES (
            NEW.fk_pk_series,
            NEW.lk_pk_pdi,
            NEW.itype,
            NEW.lk_pk_source,
            NEW.value,
            FALSE,
            'I',
            ce_warehouse.fx_ut__session_uid()
        );

        -- upsert x_series_meta
        INSERT INTO ce_warehouse.x__series_meta (
            fk_pk_series, ifreq, itype, sid1, first_pdi, last_pdi, is_has_values, ts_new_values
        )
        VALUES (
            NEW.fk_pk_series, NEW.ifreq, NEW.itype, _sid1, NEW.pdi, NEW.pdi, TRUE, _now
        )
        ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET sid1 = EXCLUDED.sid1,
                    first_pdi = LEAST(COALESCE(x_series_meta.first_pdi, EXCLUDED.first_pdi), EXCLUDED.first_pdi),
                    last_pdi  = GREATEST(COALESCE(x_series_meta.last_pdi, EXCLUDED.last_pdi), EXCLUDED.last_pdi),
                    is_has_values = EXCLUDED.is_has_values,
                    ts_new_values = EXCLUDED.ts_new_values,
                    ts_updated = _now
            WHERE x_series_meta.sid1 IS DISTINCT FROM EXCLUDED.sid1
            OR x_series_meta.first_pdi IS DISTINCT FROM EXCLUDED.first_pdi
            OR x_series_meta.last_pdi IS DISTINCT FROM EXCLUDED.last_pdi
            OR x_series_meta.is_has_values IS DISTINCT FROM EXCLUDED.is_has_values
            OR x_series_meta.ts_new_values IS DISTINCT FROM EXCLUDED.ts_new_values;

    ELSEIF TG_OP = 'UPDATE' THEN

        /***************************************************************************
         * UPDATE
         ***************************************************************************/

        IF (OLD.value IS DISTINCT FROM NEW.value)
            OR (OLD.itype IS DISTINCT FROM NEW.itype)
            OR (OLD.lk_pk_source IS DISTINCT FROM NEW.lk_pk_source) THEN

            INSERT INTO ce_warehouse.a_xvalue (
                fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, new_value, realised, audit_type, audit_user
            )
            VALUES (
                OLD.fk_pk_series,
                OLD.lk_pk_pdi,
                OLD.itype,
                OLD.lk_pk_source,
                OLD.value,
                NEW.value,
                (OLD.itype = 2 AND NEW.itype = 1),
                'U',
                ce_warehouse.fx_ut__session_uid()
            );

            -- update x_series_meta
            INSERT INTO ce_warehouse.x__series_meta (
                fk_pk_series, ifreq, itype, sid1, is_has_values, ts_updated_values
            )
            VALUES (
                OLD.fk_pk_series, OLD.ifreq, OLD.itype, _sid1, TRUE, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
                DO UPDATE
                    SET sid1 = EXCLUDED.sid1,
                        is_has_values = EXCLUDED.has_values,
                        ts_updated_values = EXCLUDED.ts_updated_values,
                        ts_updated = _now
                WHERE x_series_meta.sid1 IS DISTINCT FROM EXCLUDED.sid1
                OR x_series_meta.is_has_values IS DISTINCT FROM EXCLUDED.is_has_values
                OR x_series_meta.ts_new_values IS DISTINCT FROM EXCLUDED.ts_new_values;
        END IF;

    ELSEIF TG_OP = 'DELETE' THEN

        /***************************************************************************
         * DELETE
         ***************************************************************************/

        INSERT INTO ce_warehouse.a_xvalue(
           fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, realised, audit_type, audit_user
        )
        VALUES (
            OLD.fk_pk_series,
            OLD.lk_pk_pdi,
            OLD.itype,
            OLD.lk_pk_source,
            OLD.value,
            FALSE,
            'D',
            ce_warehouse.fx_ut__session_uid()
        );

        -- recompute bounds
        SELECT MIN(lk_pk_pdi), MAX(lk_pk_pdi) INTO _first_pdi, _last_pdi
        FROM ce_warehouse.x__value
        WHERE fk_pk_series = OLD.fk_pk_series
        AND ifreq = OLD.ifreq
        AND itype = OLD.itype;

        INSERT INTO ce_warehouse.x__series_meta(
            fk_pk_series, ifreq, itype, sid1, first_pdi, last_pdi, is_has_values, ts_updated_values
        )
        VALUES (
            OLD.fk_pk_series, OLD.ifreq, OLD.itype, OLD.sid1, _first_pdi, _last_pdi, (_first_pdi IS NOT NULL), _now
        )
        ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET sid1 = EXCLUDED.sid1,
                    first_pdi = EXCLUDED.first_pdi,
                    last_pdi  = EXCLUDED.last_pdi,
                    is_has_values = EXCLUDED.has_values,
                    ts_updated_values = EXCLUDED.ts_updated_values,
                    ts_updated = _now
            WHERE x_series_meta.sid1 IS DISTINCT FROM EXCLUDED.sid1
            OR x_series_meta.first_pdi IS DISTINCT FROM EXCLUDED.first_pdi
            OR x_series_meta.last_pdi IS DISTINCT FROM EXCLUDED.last_pdi
            OR x_series_meta.is_has_values IS DISTINCT FROM EXCLUDED.is_has_values
            OR x_series_meta.ts_new_values IS DISTINCT FROM EXCLUDED.ts_new_values;

    END IF;

    -- No need to return a record since this is an AFTER trigger
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__xvalue__audit
    IS 'Trigger function - log changes in x_value to custom audit table (AFTER update)';
