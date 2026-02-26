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
        xs.sid3                   AS skey,
        x.pdi                     AS pk,  -- Period "Key"
        CASE x.itype WHEN 1 THEN 'AC' WHEN 2 THEN 'F' END
                                  AS t_code,
        CASE
            WHEN s.precision IS NOT NULL AND s.precision BETWEEN 0 AND 12 THEN
                 ROUND(x.value, s.precision)
            ELSE x.value
        END                        AS value,
        CASE
            WHEN s.precision IS NOT NULL AND s.precision BETWEEN 0 AND 12 THEN
                 ROUND(a.old_value, s.precision)
            ELSE a.old_value
        END                        AS old_value,
        x.updated_utc              AS updated_utc,
        t.tooltip                  AS tip,
        src.api_available          AS api_available,
        d.downloadable             AS downloadable,
        -- Adjustment date: only used by API
        CASE s.date_point
            WHEN 'start' THEN p.start_of_period
            WHEN 'end' THEN p.end_of_period
            ELSE p.mid_of_period
        END                        AS adj_date

    FROM
		ce_warehouse.x_value x

        JOIN ce_warehouse.x_series_meta xs
            ON xs.fk_pk_series = x.fk_pk_series
            AND xs.ifreq = x.ifreq
            AND xs.itype = x.itype

        JOIN ce_warehouse.c_series s
            ON s.pk_series = x.fk_pk_series

        JOIN ce_warehouse.c_series_downloadable d
            ON d.fk_pk_series = x.fk_pk_series
            AND d.ifreq = x.ifreq
            AND d.itype = x.itype

        JOIN ce_warehouse.l_source src
            ON src.pk_source = x.isource

        JOIN ce_warehouse.mv_period p
            ON p.pk_pdi = x.pdi

        LEFT JOIN ce_warehouse.x_tooltip t
            ON t.pk_tip = x.fk_pk_tip

        -- Get "old value" from audit
        LEFT JOIN LATERAL (
            SELECT value AS old_value
            FROM ce_warehouse.a_x_value ax
            WHERE ax.fk_pk_series = x.fk_pk_series
            AND ax.pdi = x.pdi
            AND ax.audit_type = 'U'
            ORDER BY ax.idx DESC
            LIMIT 1
        ) a ON TRUE;

COMMENT ON VIEW ce_plugin.v_series_data_data
    IS 'View - for Excel plugin series data "data"';
