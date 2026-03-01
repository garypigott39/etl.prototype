/*
 ***********************************************************************************************************
 * @file
 * tg__cseries_data_source__a99.sql
 *
 * Trigger to audit changes to the c_series_data_source table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cseries_data_source__a99 ON ce_warehouse.c__series_data_source;

CREATE TRIGGER tg__cseries_data_source__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__series_data_source
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg__cseries_data_source__a99 ON ce_warehouse.c__series_data_source
    IS 'Trigger to audit changes to the c_series_data_source table';
