/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_date.sql
 *
 * Utility function - returns a default value for NULL date dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_date;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_date(
    _val DATE DEFAULT NULL
)
    RETURNS DATE
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS
$$
    SELECT COALESCE(_val, '1799-12-31'::DATE)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_date
    IS 'Utility function - returns a default value for NULL date dimension';
