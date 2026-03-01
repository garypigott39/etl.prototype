/*
 ***********************************************************************************************************
 * @file
 * tg__cgeo_group__a99.sql
 *
 * Trigger to audit changes to the c_geo_group table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cgeo_group__a99 ON ce_warehouse.c__geo_group;

CREATE TRIGGER tg__cgeo_group__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__geo_group
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg__cgeo_group__a99 ON ce_warehouse.c__geo_group
    IS 'Trigger to audit changes to the c_geo_group table';
