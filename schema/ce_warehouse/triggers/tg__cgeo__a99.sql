/*
 ***********************************************************************************************************
 * @file
 * tg__cgeo__a99.sql
 *
 * Trigger to audit changes to the c_geo table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cgeo__a99 ON ce_warehouse.c__geo;

CREATE TRIGGER tg__cgeo__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__geo
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_geo');

COMMENT ON TRIGGER tg__cgeo__a99 ON ce_warehouse.c__geo
    IS 'Trigger to audit changes to the c_geo table';
