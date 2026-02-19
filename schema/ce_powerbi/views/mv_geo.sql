/*
 ***********************************************************************************************************
 * @file
 * mv_geo.sql
 *
 * Materialized View - geo lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_geo;

CREATE MATERIALIZED VIEW ce_powerbi.mv_geo
AS
    SELECT
        pk_geo,
        geo_code,
        ce_powerbi.fx_ut_null_text(g.geo_name)           AS geo_name,
        ce_powerbi.fx_ut_null_text(g.geo_name2)          AS geo_name2,
        SUBSTR(g.geo_code, 3)                            AS geo_short_code,
        ce_powerbi.fx_ut_null_text(g.geo_short_name)     AS geo_short_name,
        ce_powerbi.fx_ut_null_text(g.geo_tla)            AS geo_tla,
        ce_powerbi.fx_ut_null_text(g.geo_iso2)           AS geo_iso2,
        ce_powerbi.fx_ut_null_text(g.geo_iso3)           AS geo_iso3,
        g.geo_lat                                        AS geo_lat,
        g.geo_long                                       AS geo_long,
        CASE
            WHEN g.geo_lat IS NOT NULL AND g.geo_long IS NOT NULL THEN TRUE
            ELSE FALSE
        END::BOOL                                        AS geo_has_coordinates,
        ce_powerbi.fx_ut_null_text(g.geo_cb)             AS geo_cb,
        ce_powerbi.fx_ut_null_text(g.geo_cb_short)       AS geo_cb_short,
        ce_powerbi.fx_ut_null_text(g.geo_stockmarket)    AS geo_stockmarket,
        ce_powerbi.fx_ut_null_text(g.geo_stockmarket_short)
                                                         AS geo_stockmarket_short,
        ce_powerbi.fx_ut_null_text(g.geo_political_alignment)
                                                         AS geo_political_alignment,
        ce_powerbi.fx_ut_null_text(g.geo_lc)             AS geo_lc,
        ce_powerbi.fx_ut_null_text(g.geo_lcu)            AS geo_lcu,
        CASE
            WHEN g.geo_flag IS NOT NULL THEN
                s.value || TRIM(LEADING '/' FROM g.geo_flag)
        END                                              AS geo_flag,
        ce_powerbi.fx_ut_null_text(g.geo_catg)           AS geo_category,
        ce_powerbi.fx_ut_null_int(g.geo_order)           AS geo_order
    FROM ce_warehouse.c_geo g
        LEFT JOIN ce_warehouse.s_sys_flags s
            ON s.code = 'GEO.FLAG.BASEURL'
    WHERE g.error IS NULL

    UNION ALL

    SELECT
        -1,
        '_undef',
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        NULL,
        NULL,
        FALSE,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int();

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_geo
    IS 'Materialized View - geo lookup';
