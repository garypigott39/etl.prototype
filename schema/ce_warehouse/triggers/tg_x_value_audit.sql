/*
 ***********************************************************************************************************
 * @file
 * tg_x_value_audit.sql
 *
 * Trigger to audit changes to the x_value table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_x_value_audit ON ce_warehouse.x_value;

CREATE TRIGGER tg_x_value_audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.x_value
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_x_value_audit();

COMMENT ON TRIGGER tg_x_value_audit ON ce_warehouse.x_value
    IS 'Trigger to audit changes to the x_value table';
