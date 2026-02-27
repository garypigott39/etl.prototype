/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_code.sql
 *
 * Validation function - simple wrapper around fx_val_is_text to validate text "code" fields.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_code;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_code(
    _val TEXT,
    _col_name TEXT DEFAULT 'DEFAULT',
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN ce_warehouse.fx_val_is_text(_val, _col_name, _nulls_allowed, 'C');
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_code
    IS 'Validation function - simple wrapper around fx_val_is_text to validate text "code" fields';
