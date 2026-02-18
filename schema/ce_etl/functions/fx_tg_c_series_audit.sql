/*
 ***********************************************************************************************************
 * @file
 * fx_tg_c_series_audit.sql
 *
 * Trigger function - log changes in c_series.
 * Note, we're only actually interested if (a) the series is DELETED or (b) the series ID changes.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_tg_c_series_audit;

CREATE OR REPLACE FUNCTION ce_etl.fx_tg_c_series_audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- do nothing!
        NULL;

    ELSEIF TG_OP = 'UPDATE' THEN
        IF OLD.s_series_id IS DISTINCT FROM NEW.s_series_id THEN
            INSERT INTO ce_etl.a_cseries (pk_s, s_series_id, audit_type)
                VALUES (OLD.pk_s, OLD.s_series_id, 'U');
        END IF;

    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO ce_etl.a_cseries (pk_s, s_series_id, audit_type)
            VALUES (OLD.pk_s, OLD.s_series_id, 'D');
    END IF;
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_etl.fx_tg_c_series_audit
    IS 'Trigger function - log changes in c_series';
