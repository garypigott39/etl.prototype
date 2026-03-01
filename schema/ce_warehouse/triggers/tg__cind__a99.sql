/*
 ***********************************************************************************************************
 * @file
 * tg__cind__a99.sql
 *
 * Trigger to audit changes to the c_ind table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cind__a99 ON ce_warehouse.c__ind;

CREATE TRIGGER tg__cind__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__ind
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_ind');

COMMENT ON TRIGGER tg__cind__a99 ON ce_warehouse.c__ind
    IS 'Trigger to audit changes to the c_ind table';
