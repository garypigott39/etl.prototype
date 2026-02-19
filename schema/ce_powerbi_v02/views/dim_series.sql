/*
 ***********************************************************************************************************
 * @file
 * dim_series.sql
 *
 * View - "dimension" table for series lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_series;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_series
AS
    SELECT * FROM ce_powerbi.mv_series;

COMMENT ON VIEW ce_powerbi_v02.dim_series
    IS 'View - "dimension" table for series lookup';
