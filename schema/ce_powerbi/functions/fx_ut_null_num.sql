/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_num.sql
 *
 * Utility function - returns a default value for NULL numeric dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_num;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_num(
    _val NUMERIC DEFAULT NULL
)
    RETURNS NUMERIC
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS
$$
    SELECT COALESCE(_val, -1::NUMERIC)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_num
    IS 'Utility function - returns a default value for NULL numeric dimension';
