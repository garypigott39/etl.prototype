/*
 ***********************************************************************************************************
 * @file
 * dim_date.sql
 *
 * View - "dimension" table for date lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_date;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_date
AS
    SELECT * FROM ce_powerbi.v_date;

COMMENT ON VIEW ce_powerbi_v02.dim_date
    IS 'View - "dimension" table for date lookup';
