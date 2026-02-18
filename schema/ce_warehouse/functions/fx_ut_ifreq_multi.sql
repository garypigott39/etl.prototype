/*
 ***********************************************************************************************************
 * @file
 * fx_ut_ifreq_multi.sql
 *
 * Utility function - returns integer-array representation of frequency codes array.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_ifreq_multi;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_ifreq_multi(
    _freqs TEXT[]
)
    RETURNS INT[]
    RETURNS NULL ON NULL INPUT
    LANGUAGE sql
    IMMUTABLE
    PARALLEL SAFE
AS
$$
    SELECT ARRAY(
        SELECT DISTINCT
        CASE f
            WHEN 'D' THEN 1
            WHEN 'W' THEN 2
            WHEN 'M' THEN 3
            WHEN 'Q' THEN 4
            WHEN 'Y' THEN 5
        END
        FROM UNNEST(_freqs) AS f
        WHERE f IS NOT NULL
        ORDER BY 1
    );
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_ifreq_multi
    IS 'Utility function - returns integer-array representation of frequency codes array';
