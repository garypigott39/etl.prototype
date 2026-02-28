/*
 ***********************************************************************************************************
 * @file
 * fx_tg_c_series__check_icode.sql
 *
 * Trigger function - check ICODE/GCODE combination on c_series after change of ICODE/GCODE fields.
 * Allows INTERNAL series to have non-existent indicators.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_c_series__check_icode;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_c_series__check_icode(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF NEW.gcode = 'INTERNAL' OR EXISTS (SELECT 1 FROM ce_warehouse.c_ind WHERE code = NEW.icode) THEN
        RETURN NEW;
    END IF;

    -- Block the change
    RAISE EXCEPTION 'Invalid ICODE % for GCODE %', NEW.icode, NEW.gcode
       USING ERRCODE = 'foreign_key_violation';
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_c_series__check_icode
    IS 'Trigger function - check ICODE/GCODE combination on c_series after change of ICODE/GCODE fields';
