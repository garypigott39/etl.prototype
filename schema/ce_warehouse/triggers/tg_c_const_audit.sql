/*
 ***********************************************************************************************************
 * @file
 * tg_c_const__after_99__audit.sql
 *
 * Trigger to audit changes to the c_const table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_const__after_99__audit ON ce_warehouse.c_const;

CREATE TRIGGER tg_c_const__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_const
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic__audit('pk_const');

COMMENT ON TRIGGER tg_c_const__after_99__audit ON ce_warehouse.c_const
    IS 'Trigger to audit changes to the c_const table';
