/*
 ***********************************************************************************************************
 * @file
 * mv_series_metadata2.sql
 *
 * Materialized view - for Excel plugin series data header.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_plugin.mv_series_metadata2;

CREATE MATERIALIZED VIEW ce_plugin.mv_series_metadata2
AS
    SELECT
        skey                                 AS skey,
        f_code                               AS f_code,
        ARRAY_AGG(DISTINCT s_downloadable)   AS downloadable,
        MIN(f_name)                          AS frequency,
        MIN(geo_short_name)                  AS geography_or_commodity,
        MIN(i_code)                          AS i_code,
        MIN(i_name1)                         AS indicator,
        MIN(s_units)                         AS units,
        MIN(s_source)                        AS historical_data_source,
        -- Actuals
        MIN(s_first_period) FILTER (WHERE t_code = 'AC') || ' to ' ||
          MAX(s_last_period) FILTER (WHERE t_code = 'AC')
                                             AS actuals_range,
        MAX(s_downloadable) FILTER (WHERE t_code = 'AC')
                                             AS actuals_availability,
        MAX(s_updated_utc) FILTER (WHERE t_code = 'AC')
                                             AS actual_last_updated,
        -- Forecasts
        MIN(s_first_period) FILTER (WHERE t_code = 'F') || ' to ' ||
        MAX(s_last_period) FILTER (WHERE t_code = 'F')
                                             AS forecasts_range,
        MAX(s_downloadable) FILTER (WHERE t_code = 'F')
                                             AS forecasts_availability,
        MAX(s_updated_utc) FILTER (WHERE t_code = 'F')
                                             AS forecast_last_updated,
        -- PRIMARY key needed for concurrent refreshes - not exposed to plugin
        ROW_NUMBER() OVER (ORDER BY skey, f_code)
                                             AS idx
    FROM ce_plugin.mv_series_metadata s
    WHERE t_code IN ('AC', 'F')
    GROUP BY
        skey, f_code;

CREATE UNIQUE INDEX IF NOT EXISTS mv_series_metadata2__unique__idx
    ON ce_plugin.mv_series_metadata2(idx);

COMMENT ON MATERIALIZED VIEW ce_plugin.mv_series_metadata2
    IS 'Materialized view - for Excel plugin series data header';
