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
        sm.sid3                   AS skey,  -- <GEO/COMMODITY>_<IND>
        s.sid1                    AS series_id,
        s.name                    AS s_name,
        COALESCE(g.short_code, c.short_code)
                                  AS geo_short_code,
        COALESCE(g.short_name, c.short_name)
                                  AS geo_short_name,
        CASE
            WHEN g.pk_geo IS NULL THEN
                'Commodity'
            ELSE 'Geography'
        END                       AS geo_type,
        i.code                    AS i_code,
        i.name1                   AS i_name1,
        f.code                    AS f_code,
        f.name                    AS f_name,
        t.code                    AS t_code,
        t.name                    AS t_name,
        s.description             AS s_description,
        s.s_source                    AS s_source,
        s.units                   AS s_units,
        s.precision               AS s_precision,
        s.date_point              AS s_date_point,
        s.s_first_date                AS s_first_date,
        s.s_last_date                 AS s_last_date,
        s.s_first_period              AS s_first_period,
        s.s_last_period               AS s_last_period,
        s.s_downloadable              AS s_downloadable,
        s.s_new_values_utc::DATE      AS s_new_values_utc,
        s.s_updated_values_utc::DATE  AS s_updated_values_utc,
        s.s_updated_utc::DATE         AS s_updated_utc,
        -- PRIMARY key needed for concurrent refreshes - not exposed to plugin
        s.pk_s                        AS idx
    FROM ce_powerbi.mv_series s
        JOIN ce_powerbi.mv_sid_xref sx
            ON sx.pk_sx = s.pk_s
    WHERE s.s_downloadable NOT IN ('none', 'internal');  -- CEP-313: Exclude "none" & "internal" from  PowerBI datasets

COMMENT ON VIEW ce_plugin.v_series_metadata
    IS 'Materialized view - for Excel plugin series metadata';
