/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_bool.sql
 *
 * Utility function - returns a default value for NULL bool dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_bool;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_bool(
    _val BOOL DEFAULT NULL
)
    RETURNS BOOL
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS $$
    SELECT COALESCE(_val, FALSE)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_bool
    IS 'Utility function - returns a default value for NULL bool dimension';
