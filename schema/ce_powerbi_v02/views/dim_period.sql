/*
 ***********************************************************************************************************
 * @file
 * dim_period.sql
 *
 * View - "dimension" table for period lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_period;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_period
AS
    SELECT * FROM ce_powerbi.v_period;

COMMENT ON VIEW ce_powerbi_v02.dim_period
    IS 'View - "dimension" table for period lookup.';
