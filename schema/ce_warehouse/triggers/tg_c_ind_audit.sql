/*
 ***********************************************************************************************************
 * @file
 * tg_c_ind__after_99__audit.sql
 *
 * Trigger to audit changes to the c_ind table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_ind__after_99__audit ON ce_warehouse.c_ind;

CREATE TRIGGER tg_c_ind__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_ind
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_ind');

COMMENT ON TRIGGER tg_c_ind__after_99__audit ON ce_warehouse.c_ind
    IS 'Trigger to audit changes to the c_ind table';
