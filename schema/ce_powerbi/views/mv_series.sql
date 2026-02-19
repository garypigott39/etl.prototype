/*
 ***********************************************************************************************************
 * @file
 * mv_series.sql
 *
 * Materialized View - series lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_series;

CREATE MATERIALIZED VIEW ce_powerbi.mv_series
AS
    SELECT
        sx.pk_sx                                     AS pk_s,  -- use the derived UNIQUE key from mv_sid_xref!!
        sx.s_id_1                                    AS s_id_1,
        sx.s_id_2                                    AS s_id_2,
        sx.s_id_3                                    AS s_id_3,
        ce_powerbi.fx_ut_null_text(s.s_name)         AS s_name,
        ce_powerbi.fx_ut_null_text(s.s_name1)        AS s_name1,
        ce_powerbi.fx_ut_null_text(s.s_name2)        AS s_name2,
        ce_powerbi.fx_ut_null_text(s.s_name3)        AS s_name3,
        ce_powerbi.fx_ut_null_text(s.s_name4)        AS s_name4,
        ce_powerbi.fx_ut_null_text(s.s_description)  AS s_description,
        ce_powerbi.fx_ut_null_text(s.s_source)       AS s_source,
        ce_powerbi.fx_ut_null_text(s.s_units)        AS s_units,
        s.s_precision                                AS s_precision,
        sx.downloadable                              AS s_downloadable,
        sx.first_date                                AS s_first_date,
        sx.last_date                                 AS s_last_date,
        ce_powerbi.fx_ut_null_text(sx.first_period)  AS s_first_period,
        ce_powerbi.fx_ut_null_text(sx.last_period)   AS s_last_period,
        ce_powerbi.fx_ut_null_text(s.s_date_point)   AS s_date_point,
        -- CEP-249: Blended flag
        sx.s_id_2_blended                            AS s_id_2_blended,
        sx.new_values_utc                            AS s_new_values_utc,
        sx.updated_values_utc                        AS s_updated_values_utc,
        sx.updated_utc                               AS s_updated_utc,
        ce_powerbi.fx_ut_null_int(s.s_order)         AS s_order
    FROM ce_warehouse.c_series s
        JOIN ce_powerbi.mv_sid_xref sx
            ON s.pk_s = sx.base_pks
    WHERE sx.downloadable NOT IN ('none', 'internal')  -- CEP-313: Exclude "none" & "internal" from  PowerBI datasets
    AND s.error IS NULL

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
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        NULL,
        ce_powerbi.fx_ut_null_text(),
        NULL,
        NULL,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        NULL,
        NULL,
        NULL,
        ce_powerbi.fx_ut_null_int();

CREATE UNIQUE INDEX IF NOT EXISTS mv_series__pk_s__idx
    ON ce_powerbi.mv_series (pk_s);

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_series
    IS 'Materialized View - series lookup';
