/*
 ***********************************************************************************************************
 * @file
 * dim_geography_group.sql
 *
 * View - "dimension" table for geography groupings.
 *
 * Note, this only applies to geographies, and as we are kind of ignoring the dim_geoc we will link the
 * primary key to "pk_g".
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.dim_geography_group;

CREATE OR REPLACE VIEW ce_powerbi_v02.dim_geography_group
AS
    SELECT * FROM ce_powerbi.mv_geo_group;

COMMENT ON VIEW ce_powerbi_v02.dim_geography_group
    IS 'View - "dimension" table for geography groupings';
