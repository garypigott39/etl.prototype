/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_email.sql
 *
 * Validation function -  - simple wrapper around fx_val__is_text to validate text "email" fields.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_email;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_email(
    _val TEXT,
    _col_email TEXT DEFAULT 'EMAIL',
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN ce_warehouse.fx_val__is_text(_val, _col_email, _nulls_allowed, 'N');
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_email
    IS 'Validation function - simple wrapper around fx_val__is_text to validate text "email" fields.';
