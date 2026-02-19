/*
 ***********************************************************************************************************
 * @file
 * dim_freq.sql
 *
 * View - "dimension" table for frequency lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_freq;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_freq
AS
    SELECT * FROM ce_powerbi.v_freq;

COMMENT ON VIEW ce_powerbi_v02.dim_freq
    IS 'View - "dimension" table for frequency lookup';
