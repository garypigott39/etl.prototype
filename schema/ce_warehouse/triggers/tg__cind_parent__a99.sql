/*
 ***********************************************************************************************************
 * @file
 * tg__cind_parent__a99.sql
 *
 * Trigger to audit changes to the c_ind_parent table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cind_parent__a99 ON ce_warehouse.c__ind_parent;

CREATE TRIGGER tg__cind_parent__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__ind_parent
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('idx');

COMMENT ON TRIGGER tg__cind_parent__a99 ON ce_warehouse.c__ind_parent
    IS 'Trigger to audit changes to the c_ind_parent table';
