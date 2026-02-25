/*
 ***********************************************************************************************************
 * @file
 * tg_c_geo_audit.sql
 *
 * Trigger to audit changes to the c_geo table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_geo_audit ON ce_warehouse.c_geo;

CREATE TRIGGER tg_c_geo_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_geo
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_audit('pk_geo');

COMMENT ON TRIGGER tg_c_geo_audit ON ce_warehouse.c_geo
    IS 'Trigger to audit changes to the c_geo table';
