/*
 ***********************************************************************************************************
 * @file
 * tg_c_ind_parent_audit.sql
 *
 * Trigger to audit changes to the c_ind_parent table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_ind_parent_audit ON ce_warehouse.c_ind_parent;

CREATE TRIGGER tg_c_ind_parent_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_ind_parent
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_audit('idx');

COMMENT ON TRIGGER tg_c_ind_parent_audit ON ce_warehouse.c_ind_parent
    IS 'Trigger to audit changes to the c_ind_parent table';
