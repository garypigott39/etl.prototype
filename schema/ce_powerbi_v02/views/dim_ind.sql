/*
 ***********************************************************************************************************
 * @file
 * dim_ind.sql
 *
 * View - "dimension" table for indicator lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_indicator;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_ind
AS
    SELECT * FROM ce_powerbi.mv_ind;

COMMENT ON VIEW ce_powerbi_v02.dim_ind
    IS 'View - "dimension" table for indicator lookup';
