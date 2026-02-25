/*
 ***********************************************************************************************************
 * @file
 * v_series_data_data.sql
 *
 * View - for Excel plugin series data "data".
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_plugin.v_series_data_data;

CREATE OR REPLACE VIEW ce_plugin.v_series_data_data
AS
    SELECT
        sm.sid3                    AS skey,
        xv.pdi                     AS pk,  -- Period "Key"
        CASE xv.itype WHEN 1 THEN 'AC' WHEN 2 THEN 'F' END
                                   AS t_code,
        CASE
            WHEN s.precision IS NOT NULL AND s.precision BETWEEN 0 AND 12 THEN
                 ROUND(xv.value, s.precision)
            ELSE xv.value
        END                        AS value,
        CASE
            WHEN xa.old_value IS NULL THEN NULL
            WHEN s.precision IS NOT NULL AND s.precision BETWEEN 0 AND 12 THEN
                 ROUND(xa.old_value, s.precision)
            ELSE xa.old_value
        END                        AS old_value,
        xv.updated_utc             AS updated_utc,
        xt.tooltip                 AS tip,
        src.api_available          AS api_available,
        sm.downloadable            AS downloadable,
        -- Adjustment date: only used by API
        CASE s.date_point
            WHEN 'start' THEN p.start_of_period
            WHEN 'end' THEN p.end_of_period
            ELSE p.mid_of_period
        END                        AS adj_date
    FROM ce_warehouse.c_series_meta sm
        JOIN ce_warehouse.c_series s
            ON s.pk_series = sm.fk_pk_series
        JOIN ce_warehouse.x_value xv
            ON xv.fk_pk_series = sm.fk_pk_series
        JOIN ce_warehouse.l_source src
            ON src.pk_source = xv.isource
        JOIN ce_warehouse.mv_period p
            ON p.pk_pdi = xv.pdi
        LEFT JOIN ce_warehouse.x_tooltip xt
            ON xt.pk_tip = xv.fk_pk_tip
        LEFT JOIN LATERAL (
            SELECT value AS old_value
            FROM ce_warehouse.a_x_value ax
            WHERE ax.fk_pk_series = xv.fk_pk_series
            AND ax.pdi = xv.pdi
            AND ax.audit_type = 'U'
            ORDER BY ax.idx DESC
            LIMIT 1
        ) xa ON TRUE;

COMMENT ON VIEW ce_plugin.v_series_data_data
    IS 'View - for Excel plugin series data "data"';
