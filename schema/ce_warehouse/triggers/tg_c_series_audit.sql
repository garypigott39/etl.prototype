/*
 ***********************************************************************************************************
 * @file
 * tg_c_series_audit.sql
 *
 * Trigger to audit changes to the c_series table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_series_audit ON ce_warehouse.c_series;

CREATE TRIGGER tg_c_series_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_series
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_audit('pk_series');

COMMENT ON TRIGGER tg_c_series_audit ON ce_warehouse.c_series
    IS 'Trigger to audit changes to the c_series table';
