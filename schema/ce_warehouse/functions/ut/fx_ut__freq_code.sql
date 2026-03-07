/*
 ***********************************************************************************************************
 * @file
 * fx_ut__freq_code.sql
 *
 * Utility function - return appropriate frequency code.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__freq_code;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__freq_code(
    _freq INT
)
    RETURNS TEXT
    LANGUAGE sql
    IMMUTABLE
    STRICT  -- equivalent to "RETURNS NULL ON NULL INPUT"
AS
$$
    SELECT CASE _freq
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'Q'
        WHEN 3 THEN 'M'
        WHEN 4 THEN 'W'
        WHEN 5 THEN 'D'
        ELSE NULL
    END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut__freq_code
    IS 'Utility function - return appropriate frequency code';
