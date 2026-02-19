/*
 ***********************************************************************************************************
 * @file
 * dim_tooltip.sql
 *
 * View - "dimension" table for tooltip lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_tooltip;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_tooltip
AS
    SELECT * FROM ce_powerbi.mv_tooltip;

COMMENT ON VIEW ce_powerbi_v02.dim_tooltip
    IS 'View - "dimension" table for tooltip lookup';
