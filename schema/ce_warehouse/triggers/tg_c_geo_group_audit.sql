/*
 ***********************************************************************************************************
 * @file
 * tg_c_geo_group__after_99__audit.sql
 *
 * Trigger to audit changes to the c_geo_group table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_geo_group__after_99__audit ON ce_warehouse.c_geo_group;

CREATE TRIGGER tg_c_geo_group__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_geo_group
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg_c_geo_group__after_99__audit ON ce_warehouse.c_geo_group
    IS 'Trigger to audit changes to the c_geo_group table';
