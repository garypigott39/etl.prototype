/*
 ***********************************************************************************************************
 * @file
 * mv_series_data_data.sql
 *
 * Materialized view - for Excel plugin series data "data".
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_plugin.mv_series_data_data;

CREATE MATERIALIZED VIEW ce_plugin.mv_series_data_data
AS
    SELECT
        s.s_id_3                   AS skey,
        v.fk_pk_p                  AS pk,  -- Period "Key"
        CASE v.fk_pk_t WHEN 1 THEN 'AC' WHEN 2 THEN 'F' END
                                   AS t_code,
        v.sv_value                 AS value,
        v.sv_old_value             AS old_value,
        v.sv_updated_utc           AS updated_utc,  -- Value record updated timestamp
        t.tip                      AS tip,
        src.api_available          AS api_available,
        v.s_downloadable           AS downloadable,
        -- Adjustment date: only used by API
        d.d_date                   AS adj_date,
        -- PRIMARY key needed for concurrent refreshes - not exposed to plugin
        v.pk_sv                    AS idx
    FROM ce_powerbi.mv_series s
        JOIN ce_powerbi.mv_fact_series_value v
            ON v.fk_pk_s = s.pk_s
        JOIN ce_powerbi.source src
            ON v.fk_pk_src = src.pk_src
        JOIN ce_powerbi.date d
            ON v.fk_pk_d = d.pk_d
        LEFT JOIN ce_powerbi.tooltip t
            ON v.fk_pk_tip = t.pk_tip;

-- Unique index to support concurrent refreshes etc
CREATE UNIQUE INDEX IF NOT EXISTS mv_series_data_data__unique__idx
    ON ce_plugin.mv_series_data_data(idx);

COMMENT ON MATERIALIZED VIEW ce_plugin.mv_series_data_data
    IS 'Materialized view - for Excel plugin series data "data"';
