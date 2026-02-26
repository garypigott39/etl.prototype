/*
 ***********************************************************************************************************
 * @file
 * tg_c_geo_group_audit.sql
 *
 * Trigger to audit changes to the c_geo_group table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_geo_group_audit ON ce_warehouse.c_geo_group;

CREATE TRIGGER tg_c_geo_group_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_geo_group
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic_audit('idx');

COMMENT ON TRIGGER tg_c_geo_group_audit ON ce_warehouse.c_geo_group
    IS 'Trigger to audit changes to the c_geo_group table';
