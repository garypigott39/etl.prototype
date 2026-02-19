/*
 ***********************************************************************************************************
 * @file
 * dim_source.sql
 *
 * View - "dimension" table for source lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_source;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_source
AS
    SELECT * FROM ce_powerbi.mv_source;

COMMENT ON VIEW ce_powerbi_v02.dim_source
    IS 'View - "dimension" table for source lookup';
