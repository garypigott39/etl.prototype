/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_text.sql
 *
 * Utility function - returns a default value for NULL text dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_text;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_text(
    _val TEXT DEFAULT NULL
)
    RETURNS TEXT
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS
$$
    SELECT COALESCE(_val, 'undef'::TEXT)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_text
    IS 'Utility function - returns a default value for NULL text dimension';
