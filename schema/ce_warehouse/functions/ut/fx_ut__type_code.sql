/*
 ***********************************************************************************************************
 * @file
 * fx_ut__type_code.sql
 *
 * Utility function - return appropriate type code.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__type_code;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__type_code(
    _type INT
)
    RETURNS TEXT
    LANGUAGE sql
    IMMUTABLE
    STRICT  -- equivalent to "RETURNS NULL ON NULL INPUT"
AS
$$
    SELECT CASE _type
        WHEN 1 THEN 'AC'
        WHEN 2 THEN 'F'
        ELSE NULL
    END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut__type_code
    IS 'Utility function - return appropriate type code';
