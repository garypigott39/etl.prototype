/*
 ***********************************************************************************************************
 * @file
 * fx_ut_trim.sql
 *
 * Utility function - trim supplied string.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_trim;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_trim(
    _str TEXT
)
    RETURNS TEXT
    RETURNS NULL ON NULL INPUT
    LANGUAGE sql
    IMMUTABLE
AS
$$
    SELECT REGEXP_REPLACE(TRIM(_str), '\s+', ' ', 'g');
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_trim
    IS 'Utility function - trim supplied string';
