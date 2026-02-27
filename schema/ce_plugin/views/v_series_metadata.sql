/*
 ***********************************************************************************************************
 * @file
 * v_series_metadata.sql
 *
 * View - for Excel plugin series metadata.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_plugin.v_series_metadata;


CREATE OR REPLACE VIEW ce_plugin.v_series_metadata
AS
    SELECT
        xsm.sid3                        AS skey,  -- <GEO/COMMODITY>_<IND>
        xsm.sid1                        AS series_id,
        s.name                          AS s_name,
        g.short_code                    AS geo_short_code,
        g.short_name                    AS geo_short_name,
        g.geo_type                      AS geo_type,
        i.code                          AS i_code,
        i.name1                         AS i_name1,
        f.code                          AS f_code,
        f.name                          AS f_name,
        t.code                          AS t_code,
        t.name                          AS t_name,
        s.description                   AS s_description,
        src.data_sources                AS s_source,
        s.units                         AS s_units,
        s.precision                     AS s_precision,
        s.date_point                    AS s_date_point,
        CASE s.date_point
            WHEN 'start' THEN first.start_of_period
            WHEN 'end' THEN first.end_of_period
            ELSE first.mid_of_period
        END                             AS s_first_date,
        CASE s.date_point
            WHEN 'start' THEN last.start_of_period
            WHEN 'end' THEN last.end_of_period
            ELSE last.mid_of_period
        END                             AS s_last_date,
        first.period                    AS s_first_period,
        last.period                     AS s_last_period,
        COALESCE(sd.downloadable, 'ess_plugin')
										AS s_downloadable,
        xsm.new_values_utc::DATE        AS s_new_values_utc,
        xsm.updated_values_utc::DATE    AS s_updated_values_utc,
        s.updated_utc::DATE             AS s_updated_utc

    FROM ce_warehouse.x_series_meta xsm
        JOIN ce_warehouse.c_series s
            ON s.pk_series = xsm.fk_pk_series
        JOIN ce_warehouse.c_geo g
            ON g.code = s.gcode
        JOIN ce_warehouse.c_ind i
            ON i.code = s.icode
        JOIN ce_warehouse.l_freq f
            ON f.pk_freq = xsm.ifreq
        JOIN ce_warehouse.l_type t
            ON t.pk_type = xsm.itype
        LEFT JOIN ce_warehouse.mv_period first
            ON first.pk_pdi = xsm.first_pdi
        LEFT JOIN ce_warehouse.mv_period last
            ON last.pk_pdi = xsm.last_pdi
		LEFT JOIN ce_warehouse.c_series_downloadable sd
			ON sd.fk_pk_series = xsm.fk_pk_series
			AND sd.ifreq = xsm.ifreq
			AND sd.itype = xsm.itype
        LEFT JOIN (
            SELECT
                sd.fk_pk_series,
                STRING_AGG(l.name, ', ' ORDER BY sd.idx) AS data_sources
            FROM ce_warehouse.c_series_data_source sd
                JOIN ce_warehouse.l_data_source l
                    ON l.pk_data_source = sd.data_source
            GROUP BY 1
        ) AS src
            ON src.fk_pk_series = xsm.fk_pk_series

    WHERE sd.downloadable NOT IN ('none', 'internal')  -- CEP-313: Exclude "none" & "internal" from  PowerBI datasets
    AND xsm.has_values = TRUE;

COMMENT ON VIEW ce_plugin.v_series_metadata
    IS 'Materialized view - for Excel plugin series metadata';
