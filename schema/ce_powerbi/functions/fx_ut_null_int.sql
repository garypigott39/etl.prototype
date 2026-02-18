/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_int.sql
 *
 * Utility function - returns a default value for NULL integer dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_int;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_int(
    _val INT DEFAULT NULL
)
    RETURNS INT
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS
$$
    SELECT COALESCE(_val, -1::INT)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_int
    IS 'Utility function - returns a default value for NULL integer dimension';
