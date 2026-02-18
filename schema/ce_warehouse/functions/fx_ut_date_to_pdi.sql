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
        CASE
            WHEN _dt IS NULL THEN
                NULL
            WHEN _freq IS NULL OR _freq < 1 OR _freq > 5 THEN
                NULL
            WHEN _freq = 1 THEN
                -- Daily: YYYYMMDD
                _freq * 100000000 + (EXTRACT(YEAR FROM _dt)::INT * 10000
                                   + EXTRACT(MONTH FROM _dt)::INT * 100
                                   + EXTRACT(DAY FROM _dt)::INT)
            WHEN _freq = 2 THEN
                -- Weekly: ISO year + ISO week
                _freq * 100000000 + (EXTRACT(ISOYEAR FROM _dt)::INT * 100
                                   + EXTRACT(WEEK FROM _dt)::INT)
            WHEN _freq = 3 THEN
                -- Monthly: YYYYMM
                _freq * 100000000 + (EXTRACT(YEAR FROM _dt)::INT * 100
                                   + EXTRACT(MONTH FROM _dt)::INT)
            WHEN _freq = 4 THEN
                -- Quarterly: YYYYQ
                _freq * 100000000 + (EXTRACT(YEAR FROM _dt)::INT * 10
                                   + ((EXTRACT(MONTH FROM _dt)::INT - 1) / 3 + 1)::INT)
            ELSE
                -- Yearly: YYYY
                _freq * 100000000 + EXTRACT(YEAR FROM _dt)::INT
        END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_date_to_pdi
    IS 'Utility function - convert date/freq to period INT (pseudo primary key)';
