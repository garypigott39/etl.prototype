/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_name.sql
 *
 * Validation function -  - simple wrapper around fx_val__is_text to validate text "name" fields.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_name;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_name(
    _val TEXT,
    _col_name TEXT DEFAULT 'DEFAULT',
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE sql
AS
$$
    SELECT ce_warehouse.fx_val__is_text(_val, _col_name, _nulls_allowed, 'N');
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_name
    IS 'Validation function - simple wrapper around fx_val__is_text to validate text "name" fields.';
