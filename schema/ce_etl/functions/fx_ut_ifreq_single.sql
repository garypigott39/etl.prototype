/*
 ***********************************************************************************************************
 * @file
 * fx_ut_ifreq_single.sql
 *
 * Utility function - returns integer mapping for frequency code.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_ut_ifreq_single;

CREATE OR REPLACE FUNCTION ce_etl.fx_ut_ifreq_single(
    _freq TEXT
)
    RETURNS INT
    LANGUAGE 'sql'
    IMMUTABLE
    PARALLEL SAFE
AS
$$
    SELECT CASE _freq
        WHEN 'D' THEN 1
        WHEN 'W' THEN 2
        WHEN 'M' THEN 3
        WHEN 'Q' THEN 4
        WHEN 'Y' THEN 5
    END;
$$;

COMMENT ON FUNCTION ce_etl.fx_ut_ifreq_single
    IS 'Utility function - returns integer mapping for frequency code';
