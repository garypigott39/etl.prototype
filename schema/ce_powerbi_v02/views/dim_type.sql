/*
 ***********************************************************************************************************
 * @file
 * dim_type.sql
 *
 * View - "dimension" table for type lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_type;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_type
AS
    SELECT * FROM ce_powerbi.v_type;

COMMENT ON VIEW ce_powerbi_v02.dim_type
    IS 'View - "dimension" table for type lookup';
