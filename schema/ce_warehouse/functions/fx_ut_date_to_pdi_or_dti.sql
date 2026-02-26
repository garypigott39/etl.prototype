/*
 ***********************************************************************************************************
 * @file
 * fx_ut_date_to_pdi_or_dti.sql
 *
 * Utility function - convert date/freq to period INT (pseudo primary key) or date INT (if frequency -1).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_date_to_pdi_or_dti;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_date_to_pdi_or_dti(
    _date DATE,
    _ifreq INT
)
    RETURNS INT
    LANGUAGE sql
    IMMUTABLE
    STRICT
AS
$$
    SELECT
        CASE _ifreq
            -- Daily: 1YYYYMMDD
            WHEN 1 THEN 100000000 +
                (
                    EXTRACT(YEAR  FROM _date)::INT * 10000 +
                    EXTRACT(MONTH FROM _date)::INT * 100 +
                    EXTRACT(DAY   FROM _date)::INT
                )

            -- Weekly: 2YYYYWW (ISO year/week)
            WHEN 2 THEN 200000000 +
                (
                    EXTRACT(ISOYEAR FROM _date)::INT * 100 +
                    EXTRACT(WEEK    FROM _date)::INT
                )

            -- Monthly: 3YYYYMM
            WHEN 3 THEN 300000000 +
                (
                    EXTRACT(YEAR  FROM _date)::INT * 100 +
                    EXTRACT(MONTH FROM _date)::INT
                )

            -- Quarterly: 4YYYYQ
            WHEN 4 THEN 400000000 +
                (
                    EXTRACT(YEAR    FROM _date)::INT * 10 +
                    EXTRACT(QUARTER FROM _date)::INT
                )

            -- Yearly: 5YYYY
            WHEN 5 THEN 500000000 +
                EXTRACT(YEAR FROM _date)::INT

            WHEN -1 THEN
                -- its a DTI conversion
                (
                    EXTRACT(YEAR  FROM _date)::INT * 10000 +
                    EXTRACT(MONTH FROM _date)::INT * 100 +
                    EXTRACT(DAY   FROM _date)::INT
                )
        END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_date_to_pdi_or_dti
    IS 'Utility function - convert date/freq to period INT (pseudo primary key), or date INT (if no frequency)';
