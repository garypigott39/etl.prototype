/*
 ***********************************************************************************************************
 * @file
 * tg__cseries_downloadable__a99.sql
 *
 * Trigger to audit changes to the c_series_downloadable table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cseries_downloadable__a99 ON ce_warehouse.c__series_downloadable;

CREATE TRIGGER tg__cseries_downloadable__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__series_downloadable
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg__cseries_downloadable__a99 ON ce_warehouse.c__series_downloadable
    IS 'Trigger to audit changes to the c_series_downloadable table';
