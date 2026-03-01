/*
 ***********************************************************************************************************
 * @file
 * tg__cseries__a99.sql
 *
 * Trigger to audit changes to the c_series table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cseries__a99 ON ce_warehouse.c__series;

CREATE TRIGGER tg__cseries__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__series
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_series');

COMMENT ON TRIGGER tg__cseries__a99 ON ce_warehouse.c__series
    IS 'Trigger to audit changes to the c_series table';
