/*
 ***********************************************************************************************************
 * @file
 * tg_c_series_data_source__after_99__audit.sql
 *
 * Trigger to audit changes to the c_series_data_source table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_series_data_source__after_99__audit ON ce_warehouse.c_series_data_source;

CREATE TRIGGER tg_c_series_data_source__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_series_data_source
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic__audit('idx');

COMMENT ON TRIGGER tg_c_series_data_source__after_99__audit ON ce_warehouse.c_series_data_source
    IS 'Trigger to audit changes to the c_series_data_source table';
