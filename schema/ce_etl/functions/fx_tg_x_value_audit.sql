/*
 ***********************************************************************************************************
 * @file
 * fx_tg_x_value_audit.sql
 *
 * Trigger function - log changes in x_value.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_tg_x_value_audit;

CREATE OR REPLACE FUNCTION ce_etl.fx_tg_x_value_audit(
)
    RETURNS TRIGGER
    LANGUAGE 'plpgsql'
AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ce_etl.a_xvalue (fk_pk_s, pdi, type, source, value, realised, audit_type)
            VALUES (NEW.fk_pk_s, NEW.pdi, NEW.type, NEW.source, NEW.value FALSE, 'I');
        -- Upsert x_series_value
        INSERT INTO ce_etl.x_series_value (fk_pk_s, freq, type, new_values_utc)
            VALUES(NEW.fk_pk_s, NEW.freq, NEW.type, NOW())
            ON CONFLICT (fk_pk_s, freq, type)
            DO UPDATE SET new_values_utc = NOW();
    ELSEIF TG_OP = 'UPDATE' THEN
        IF OLD.type IS DISTINCT FROM NEW.type OR
           OLD.source IS DISTINCT FROM NEW.source OR
           OLD.value IS DISTINCT FROM NEW.value THEN
          INSERT INTO ce_etl.a_xvalue (fk_pk_s, pdi, type, source, value, new_value, realised, audit_type)
             VALUES (
                  OLD.fk_pk_s,
                  OLD.pdi,
                  OLD.type,    -- Log the OLD type, @see CEP-633
                  OLD.source,  -- Log the OLD source, @see CEP-633
                  OLD.value,
                  NEW.value,
                  (OLD.type = 2 AND NEW.type = 1),  -- Realised if 2=(F)orecast becomes 1=(AC)tuals
                  'U'
              );
            -- Upsert x_series_value
            INSERT INTO ce_etl.x_series_value (fk_pk_s, freq, type, updated_values_utc)
                VALUES(NEW.fk_pk_s, NEW.freq, NEW.type, NOW())
                ON CONFLICT (fk_pk_s, freq, type)
                DO UPDATE SET updated_values_utc = NOW();
        END IF;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO ce_etl.a_xvalue (fk_pk_s, pdi, type, source, value, realised, audit_type)
            VALUES (OLD.fk_pk_s, OLD.pdi, OLD.type, OLD.source, OLD.value FALSE, 'D');
        -- Upsert x_series_value
        INSERT INTO ce_etl.x_series_value (fk_pk_s, freq, type, updated_values_utc)
            VALUES(NEW.fk_pk_s, NEW.freq, NEW.type, NOW())
            ON CONFLICT (fk_pk_s, freq, type)
            DO UPDATE SET updated_values_utc = NOW();
    END IF;
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_etl.fx_tg_x_value_audits
    IS 'Trigger function - log changes in x_value';
