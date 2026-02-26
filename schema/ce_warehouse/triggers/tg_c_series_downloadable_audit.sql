/*
 ***********************************************************************************************************
 * @file
 * tg_c_series_downloadable_audit.sql
 *
 * Trigger to audit changes to the c_series_downloadable table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_series_downloadable_audit ON ce_warehouse.c_series_downloadable;

CREATE TRIGGER tg_c_series_downloadable_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_series_downloadable
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic_audit('idx');

COMMENT ON TRIGGER tg_c_series_downloadable_audit ON ce_warehouse.c_series_downloadable
    IS 'Trigger to audit changes to the c_series_downloadable table';
