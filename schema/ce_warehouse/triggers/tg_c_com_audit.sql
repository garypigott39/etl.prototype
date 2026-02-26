/*
 ***********************************************************************************************************
 * @file
 * tg_c_com_audit.sql
 *
 * Trigger to audit changes to the c_com table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_com_audit ON ce_warehouse.c_com;

CREATE TRIGGER tg_c_com_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_com
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic_audit('pk_com');

COMMENT ON TRIGGER tg_c_com_audit ON ce_warehouse.c_com
    IS 'Trigger to audit changes to the c_com table';
