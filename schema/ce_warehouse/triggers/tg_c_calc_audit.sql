/*
 ***********************************************************************************************************
 * @file
 * tg_c_calc_audit.sql
 *
 * Trigger to audit changes to the c_calc table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_calc_audit ON ce_warehouse.c_calc;

CREATE TRIGGER tg_c_calc_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_calc
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_audit('pk_calc');

COMMENT ON TRIGGER tg_c_calc_audit ON ce_warehouse.c_calc
    IS 'Trigger to audit changes to the c_calc table';
