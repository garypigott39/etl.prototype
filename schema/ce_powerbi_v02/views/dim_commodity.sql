/*
 ***********************************************************************************************************
 * @file
 * dim_commodity.sql
 *
 * View - "dimension" table for commodity lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_commodity;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_commodity
AS
    SELECT * FROM ce_powerbi.mv_com;

COMMENT ON VIEW ce_powerbi_v02.dim_commodity
    IS 'View - "dimension" table for commodity lookup';
