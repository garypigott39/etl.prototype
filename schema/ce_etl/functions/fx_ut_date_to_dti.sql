/*
 ***********************************************************************************************************
 * @file
 * fx_ut_date_to_dti.sql
 *
 * Utility function - convert date to date INT (pseudo primary key).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_ut_date_to_dti;

CREATE OR REPLACE FUNCTION ce_etl.fx_ut_date_to_dti(
    _dt DATE
)
    RETURNS INT
    LANGUAGE sql
    IMMUTABLE
AS
$$
    SELECT
        CASE
            WHEN _dt IS NULL THEN
                NULL
            ELSE
                (EXTRACT(YEAR FROM _dt)::INT * 10000 +
                 EXTRACT(MONTH FROM _dt)::INT * 100 +
                 EXTRACT(DAY FROM _dt)::INT)
        END;
$$;

COMMENT ON FUNCTION ce_etl.fx_ut_date_to_pdi
    IS 'Utility function - convert date to date INT (pseudo primary key)';
