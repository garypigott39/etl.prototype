/*
 ***********************************************************************************************************
 * @file
 * fx_tg_c_series__delete.sql
 *
 * Trigger function - update "values" associated with this series to be deleted (BEFORE DELETE).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_c_series__delete;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_c_series__delete(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE ce_warehouse.x_value
    SET
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_c_series__delete
    IS 'Trigger function - update "values" associated with this series to be deleted (BEFORE DELETE)';
