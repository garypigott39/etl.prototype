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
    _has_changed BOOL;
    _has_values BOOL;

BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ce_warehouse.a_xvalue (fk_pk_series, pdi, itype, isource, value, realised, audit_type)
            VALUES (
                NEW.fk_pk_series, NEW.pdi, NEW.itype, NEW.isource, NEW.value, FALSE, 'I'
            );

        -- Upsert c_series_meta
        INSERT INTO ce_warehouse.c_series_meta (fk_pk_series, ifreq, itype, has_values, new_values_utc)
            VALUES (
                NEW.fk_pk_series, NEW.ifreq, NEW.itype, TRUE, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET has_values = TRUE,
                    updated_values_utc = _now,
                    updated_utc = _now;

        RETURN NULL;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        _has_changed :=
            (OLD.value IS DISTINCT FROM NEW.value) OR
            (OLD.type IS DISTINCT FROM NEW.type) OR
            (OLD.source IS DISTINCT FROM NEW.source);

        IF _has_changed THEN
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

        -- Upsert c_series_meta
        _has_values := EXISTS(
            SELECT 1 FROM ce_warehouse.x_value
            WHERE fk_pk_series = OLD.fk_pk_series AND ifreq = OLD.ifreq AND itype = OLD.itype
        );

        INSERT INTO ce_warehouse.c_series_meta (fk_pk_series, ifreq, itype, has_values, updated_values_utc)
            VALUES(
                OLD.fk_pk_series, OLD.ifreq, OLD.itype, _has_values, _now
            )
            ON CONFLICT (fk_pk_series, ifreq, itype)
            DO UPDATE
                SET has_values = _has_values,
                    updated_values_utc = _now,
                    updated_utc = _now;
    END IF;
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_x_value_audit
    IS 'Trigger function - log changes in x_value';
