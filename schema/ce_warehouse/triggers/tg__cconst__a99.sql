/*
 ***********************************************************************************************************
 * @file
 * tg__cconst__a99.sql
 *
 * Trigger to audit changes to the c_const table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__cconst__a99 ON ce_warehouse.c__const;

CREATE TRIGGER tg__cconst__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.c__const
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__generic__audit('pk_const');

COMMENT ON TRIGGER tg__cconst__a99 ON ce_warehouse.c__const
    IS 'Trigger to audit changes to the c_const table';
