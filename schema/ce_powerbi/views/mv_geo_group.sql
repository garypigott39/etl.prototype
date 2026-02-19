/*
 ***********************************************************************************************************
 * @file
 * mv_geo_group.sql
 *
 * Materialized View - geo groupings lookup.
 *
 * Note, this only applies to geographies, and as we are kind of ignoring the dim_geoc we will link the
 * primary key to "pk_g".
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_geo_group;

CREATE MATERIALIZED VIEW ce_powerbi.mv_geo_group
AS
    SELECT
	    ROW_NUMBER() OVER (ORDER BY g.pk_geo, l.code)
	                  AS pk_gp,
        g.pk_geo      AS fk_pk_g,
        l.code        AS gp_id,
        l.name        AS gp_name
    FROM ce_warehouse.c_geo g
        CROSS JOIN LATERAL UNNEST(g.geo_groups) AS raw(code)
        JOIN ce_warehouse.l_geo_group l
            ON raw.code = l.code
    WHERE g.geo_groups IS NOT NULL
    AND g.error IS NULL;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_geo_group
    IS 'Materialized View - geo groupings lookup';
