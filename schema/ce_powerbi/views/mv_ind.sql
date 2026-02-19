/*
 ***********************************************************************************************************
 * @file
 * mv_ind.sql
 *
 * Materialized View - indicator lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_ind;

CREATE MATERIALIZED VIEW ce_powerbi.mv_ind
AS
    SELECT
        pk_i                                       AS pk_i,  -- use the surrogate key from c_ind!!
        i_code                                     AS i_code,
        ce_powerbi.fx_ut_null_text(i_name)         AS i_name,
        ce_powerbi.fx_ut_null_text(i_description)  AS i_description,
        ce_powerbi.fx_ut_null_text(i_name1)        AS i_name1,
        ce_powerbi.fx_ut_null_text(i_name2)        AS i_name2,
        ce_powerbi.fx_ut_null_text(i_name3)        AS i_name3,
        ce_powerbi.fx_ut_null_text(i_name4)        AS i_name4,
        ce_powerbi.fx_ut_null_text(i_name_lower)   AS i_name_lower,
        ce_powerbi.fx_ut_null_text(i_name1_lower)  AS i_name1_lower,
        ce_powerbi.fx_ut_null_text(i_name2_lower)  AS i_name2_lower,
        ce_powerbi.fx_ut_null_text(i_name3_lower)  AS i_name3_lower,
        ce_powerbi.fx_ut_null_text(i_name4_lower)  AS i_name4_lower,
        ce_powerbi.fx_ut_null_text(i_catg_broad)   AS i_catg_broad,
        ce_powerbi.fx_ut_null_text(i_catg_narrow)  AS i_catg_narrow,
        ce_powerbi.fx_ut_null_text(i_data_transformation)
                                                   AS i_data_transformation,
        ce_powerbi.fx_ut_null_bool(i_keyindicator) AS i_keyindicator,
        ce_powerbi.fx_ut_null_bool(i_proprietary_data)
                                                   AS i_proprietary_data,
        ce_powerbi.fx_ut_null_int(i_order)         AS i_order
    FROM ce_warehouse.c_ind
    WHERE error IS NULL

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
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_bool(),
        ce_powerbi.fx_ut_null_bool(),
        ce_powerbi.fx_ut_null_int();

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_ind
    IS 'Materialized View - indicator lookup';
