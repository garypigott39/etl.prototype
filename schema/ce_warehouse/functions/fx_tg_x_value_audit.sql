/*
 ***********************************************************************************************************
 * @file
 * fx_tg_x_value_audit.sql
 *
 * Trigger function - log changes in x_value.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_x_value_audit;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_x_value_audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _now TIMESTAMPTZ := NOW();
    _first_pdi INT;
    _last_pdi INT;

BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ce_warehouse.a_xvalue (fk_pk_series, pdi, itype, isource, value, realised, audit_type)
            VALUES (
                NEW.fk_pk_series, NEW.pdi, NEW.itype, NEW.isource, NEW.value, FALSE, 'I'
            );

        -- Upsert c_series_meta
        INSERT INTO ce_warehouse.c_series_meta (fk_pk_series, ifreq, itype, first_pdi, last_pdi, has_values, new_values_utc)
            VALUES (
                NEW.fk_pk_series, NEW.ifreq, NEW.itype, NEW.pdi, NEW.pdi, TRUE, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET first_pdi = LEAST(COALESCE(c_series_meta.first_pdi, NEW.pdi), NEW.pdi),
                    last_pdi = GREATEST(COALESCE(c_series_meta.last_pdi, NEW.pdi), NEW.pdi),
                    has_values = TRUE,
                    updated_values_utc = _now,
                    updated_utc = _now;

        RETURN NULL;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF  (OLD.value IS DISTINCT FROM NEW.value) OR
            (OLD.type IS DISTINCT FROM NEW.type) OR
            (OLD.source IS DISTINCT FROM NEW.source) THEN

            INSERT INTO ce_warehouse.a_xvalue (fk_pk_series, pdi, itype, isource, value, new_value, realised, audit_type)
                VALUES (
                    OLD.fk_pk_series,
                    OLD.pdi,
                    OLD.itype,    -- Log the OLD type, @see CEP-633
                    OLD.isource,  -- Log the OLD source, @see CEP-633
                    OLD.value,
                    NEW.value,
                    (OLD.itype = 2 AND NEW.itype = 1),  -- Realised if 2=(F)orecast becomes 1=(AC)tuals
                    'U'
                );

            -- Upsert c_series_meta
            INSERT INTO ce_warehouse.c_series_meta (fk_pk_series, ifreq, itype, has_values, updated_values_utc)
                VALUES (
                    OLD.fk_pk_series, OLD.ifreq, OLD.itype, TRUE, _now
                )
                ON CONFLICT (fk_pk_series, ifreq, itype)
                DO UPDATE
                    SET has_values = TRUE,
                        updated_values_utc = _now,
                        updated_utc = _now;
        END IF;

        RETURN NULL;
    END IF;

    IF TG_OP = 'DELETE' THEN
        INSERT INTO ce_warehouse.a_xvalue (fk_pk_series, pdi, itype, isource, value, realised, audit_type)
            VALUES (
                OLD.fk_pk_series, OLD.pdi, OLD.itype, OLD.isource, OLD.value, FALSE, 'D'
            );

        INSERT INTO ce_warehouse.c_series_meta (fk_pk_series, ifreq, itype, first_pdi, last_pdi, has_values, updated_values_utc)
            VALUES(
                OLD.fk_pk_series, OLD.ifreq, OLD.itype, NULL, NULL, _has_values, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET first_pdi =
                    CASE
                        WHEN OLD.pdi = c_series_meta.first_pdi THEN
                        (
                            SELECT MIN(pdi) FROM ce_warehouse.x_value
                            WHERE fk_pk_series = OLD.fk_pk_series
                            AND ifreq = OLD.ifreq
                            AND itype = OLD.itype
                            ORDER BY pdi
                            LIMIT 1
                        )
                        ELSE c_series_meta.first_pdi
                    END,

                    last_pdi =
                    CASE
                        WHEN OLD.pdi = c_series_meta.last_pdi THEN
                        (
                            SELECT pdi FROM ce_warehouse.x_value
                            WHERE fk_pk_series = OLD.fk_pk_series
                            AND ifreq = OLD.ifreq
                            AND itype = OLD.itype
                            ORDER BY pdi DESC
                            LIMIT 1
                        )
                    ELSE c_series_meta.last_pdi
                    END,

                    has_values = EXISTS (
                        SELECT 1 FROM ce_warehouse.x_value
                        WHERE fk_pk_series = OLD.fk_pk_series
                        AND ifreq = OLD.ifreq
                        AND itype = OLD.itype
                    )

                    updated_values_utc = _now,
                    updated_utc = _now;
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_x_value_audit
    IS 'Trigger function - log changes in x_value';
