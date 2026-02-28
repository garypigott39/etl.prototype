/*
 ***********************************************************************************************************
 * @file
 * tg_c_series__after_99__audit.sql
 *
 * Trigger to audit changes to the c_series table.
 ***********************************************************************************************************
 */

-- DROP TRIGGER IF EXISTS tg_c_series__after_99__audit ON ce_warehouse.c_series;

CREATE TRIGGER tg_c_series__after_99__audit
    AFTER INSERT OR UPDATE OR DELETE ON ce_warehouse.c_series
    FOR EACH ROW
        EXECUTE FUNCTION ce_warehouse.fx_tg_generic__audit('pk_series');

COMMENT ON TRIGGER tg_c_series__after_99__audit ON ce_warehouse.c_series
    IS 'Trigger to audit changes to the c_series table';
