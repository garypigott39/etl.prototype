/*
 ***********************************************************************************************************
 * @file
 * mv_series_metadata.sql
 *
 * Materialized view - for Excel plugin series metadata.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_plugin.mv_series_metadata;

CREATE MATERIALIZED VIEW ce_plugin.mv_series_metadata
AS
    SELECT
        s.s_id_3                      AS skey,  -- <GEO/COMMODITY>_<IND>
        s.s_id_1                      AS series_id,
        s.s_name                      AS s_name,
        sx.geo_short_code             AS geo_short_code,
        sx.geo_short_name             AS geo_short_name,
        sx.geo_type                   AS geo_type,
        sx.i_code                     AS i_code,
        sx.i_name1                    AS i_name1,
        sx.freq_code                  AS f_code,
        sx.freq_name                  AS f_name,
        sx.freq_code                  AS t_code,
        sx.type_name                  AS t_name,
        s.s_description               AS s_description,
        s.s_source                    AS s_source,
        s.s_units                     AS s_units,
        s.s_precision                 AS s_precision,
        s.s_date_point                AS s_date_point,
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

CREATE UNIQUE INDEX IF NOT EXISTS mv_series_metadata___unique__idx
    ON ce_plugin.mv_series_metadata(idx);  -- see s_id_1 also

COMMENT ON MATERIALIZED VIEW ce_plugin.mv_series_metadata
    IS 'Materialized view - for Excel plugin series metadata';
