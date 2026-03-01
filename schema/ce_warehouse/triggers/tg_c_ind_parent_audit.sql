/*
 ***********************************************************************************************************
 * @file
 * tg_c_ind_parent__after_99__audit.sql
 *
 * Trigger to audit changes to the c_ind_parent table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_ind_parent__after_99__audit ON ce_warehouse.c_ind_parent;

CREATE TRIGGER tg_c_ind_parent__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_ind_parent
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg_c_ind_parent__after_99__audit ON ce_warehouse.c_ind_parent
    IS 'Trigger to audit changes to the c_ind_parent table';
