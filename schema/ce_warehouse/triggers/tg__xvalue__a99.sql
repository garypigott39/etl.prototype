/*
 ***********************************************************************************************************
 * @file
 * tg_x_value__a99.sql
 *
 * Trigger to audit changes to the x_value table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg__xvalue__a99 ON ce_warehouse.x__value;

CREATE TRIGGER tg__xvalue__a99
    AFTER INSERT OR UPDATE OR DELETE
        ON ce_warehouse.x__value
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__x_value__audit();

COMMENT ON TRIGGER tg__xvalue__a99 ON ce_warehouse.x__value
    IS 'Trigger to audit changes to the x_value table';
