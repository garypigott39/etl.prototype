/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_url.sql
 *
 * Validation function -  - simple wrapper around fx_val__is_text to validate text "url" fields.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_url;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_url(
    _val TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE sql
AS
$$
    SELECT ce_warehouse.fx_val__is_text(_val, 'url', _nulls_allowed, 'N');
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_url
    IS 'Validation function - simple wrapper around fx_val__is_text to validate text "url" fields.';
