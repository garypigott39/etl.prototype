/*
 ***********************************************************************************************************
 * @file
 * tg__ccalc__a99.sql
 *
 * Trigger to audit changes to the c_calc table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__ccalc__a99 ON ce_warehouse.c__calc;

CREATE TRIGGER tg__ccalc__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__calc
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_calc');

COMMENT ON TRIGGER tg__ccalc__a99 ON ce_warehouse.c__calc
    IS 'Trigger to audit changes to the c_calc table';
