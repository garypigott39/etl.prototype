/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_name.sql
 *
 * Validation function -  - simple wrapper around fx_val_is_text to validate text "name" fields.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_name;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_name(
    _val TEXT,
    _col_name TEXT DEFAULT 'DEFAULT',
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN ce_warehouse.fx_val_is_text(_val, _col_name, _nulls_allowed, 'N');
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_name
    IS 'Validation function - simple wrapper around fx_val_is_text to validate text "name" fields.';
