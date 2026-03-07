/*
 ***********************************************************************************************************
 * @file
 * fx_ut__trim.sql
 *
 * Utility function - trim supplied string.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__trim;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__trim(
    _str TEXT
)
    RETURNS TEXT
    LANGUAGE sql
    IMMUTABLE
    STRICT  -- equivalent to "RETURNS NULL ON NULL INPUT"
AS
$$
    SELECT REGEXP_REPLACE(TRIM(_str), '\s+', ' ', 'g');
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut__trim
    IS 'Utility function - trim supplied string';
