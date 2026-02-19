/*
 ***********************************************************************************************************
 * @file
 * dim_geography.sql
 *
 * View - "dimension" table for geo lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_geography;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_geography
AS
    SELECT * FROM ce_powerbi.mv_geo;

COMMENT ON VIEW ce_powerbi_v02.dim_geography
    IS 'View - "dimension" table for geo lookup';
