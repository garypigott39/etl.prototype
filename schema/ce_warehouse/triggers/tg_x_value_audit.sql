/*
 ***********************************************************************************************************
 * @file
 * tg_x_value__after_99__audit.sql
 *
 * Trigger to audit changes to the x_value table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_x_value__after_99__audit ON ce_warehouse.x_value;

CREATE TRIGGER tg_x_value__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.x_value
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg__x_value__audit();

COMMENT ON TRIGGER tg_x_value__after_99__audit ON ce_warehouse.x_value
    IS 'Trigger to audit changes to the x_value table';
