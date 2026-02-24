/*
 ***********************************************************************************************************
 * @file
 * fx_ut_date_to_pdi.sql
 *
 * Utility function - convert date/freq to period INT (pseudo primary key).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_date_to_pdi;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_date_to_pdi(
    _dt DATE,
    _freq INT
)
    RETURNS INT
    RETURNS NULL ON NULL INPUT
    LANGUAGE sql
    IMMUTABLE
AS
$$
    SELECT
        CASE _freq
            WHEN 1 THEN
                -- Daily: YYYYMMDD
                100000000 + TO_CHAR(_dt, 'YYYYMMDD')::INT
            WHEN 2 THEN
                -- Weekly: ISO year + ISO week
                200000000 + TO_CHAR(_dt, 'IYYYIW')::INT
            WHEN 3 THEN
                -- Monthly: YYYYMM
                300000000 + TO_CHAR(_dt, 'YYYYMM')::INT
            WHEN 4 THEN
                -- Quarterly: YYYYQ
                400000000 + TO_CHAR(_dt, 'YYYYQ')::INT
            WHEN 5 THEN
                -- Yearly: YYYY
                500000000 + TO_CHAR(_dt, 'YYYY')::INT
            ELSE
                NULL
        END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_date_to_pdi
    IS 'Utility function - convert date/freq to period INT (pseudo primary key)';
