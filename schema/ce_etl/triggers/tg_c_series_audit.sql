/*
 ***********************************************************************************************************
 * @file
 * tg_c_series_audit.sql
 *
 * Trigger to audit changes to the c_series table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_series_audit ON ce_etl.c_series;

CREATE TRIGGER tg_c_series_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_etl.c_series
    FOR EACH ROW EXECUTE FUNCTION ce_etl.fx_tg_c_series_audit();

COMMENT ON TRIGGER tg_c_series_audit
    ON ce_etl.c_series
    IS 'Trigger to audit changes to the c_series table';
