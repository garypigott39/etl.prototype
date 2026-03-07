/*
 ***********************************************************************************************************
 * @file
 * tg__cseries_meta__a99.sql
 *
 * Trigger to audit changes to the c_series_meta table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cseries_meta__a99 ON ce_warehouse.c__series_meta;

CREATE TRIGGER tg__cseries_meta__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__series_meta
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__general_audit('idx');

COMMENT ON TRIGGER tg__cseries_meta__a99 ON ce_warehouse.c__series_meta
    IS 'Trigger to audit changes to the c_series_meta table';
