/*
 ***********************************************************************************************************
 * @file
 * fx_ut_null_ts.sql
 *
 * Utility function - returns a default value for NULL timestamp dimension.
 *
 * Note, this has been refactored as a "FAST" function to essentially inline the logic for performance
 * reasons - and is therefore only called ONCE per query in the materialized view definition.
 *
 * @Thanks to ChatGPT for helping with the initial function creation!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_powerbi.fx_ut_null_ts;

CREATE OR REPLACE FUNCTION ce_powerbi.fx_ut_null_ts(
    _val TIMESTAMP DEFAULT NULL
)
    RETURNS TIMESTAMP
    LANGUAGE 'sql'
    IMMUTABLE PARALLEL SAFE
AS
$$
    SELECT COALESCE(_val, '1899-12-31 00:00:00'::TIMESTAMP)
$$;

COMMENT ON FUNCTION ce_powerbi.fx_ut_null_ts
    IS 'Utility function - returns a default value for NULL timestamp dimension';
