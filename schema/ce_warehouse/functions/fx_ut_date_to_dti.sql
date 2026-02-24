/*
 ***********************************************************************************************************
 * @file
 * fx_ut_date_to_dti.sql
 *
 * Utility function - convert date to date INT (pseudo primary key).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_date_to_dti;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_date_to_dti(
    _dt DATE
)
    RETURNS INT
    RETURNS NULL ON NULL INPUT
    LANGUAGE sql
    IMMUTABLE
AS
$$
    SELECT TO_CHAR(_dt, 'YYYYMMDD')::INT;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_date_to_dti
    IS 'Utility function - convert date to date INT (pseudo primary key)';
