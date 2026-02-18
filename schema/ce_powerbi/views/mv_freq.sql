/*
 ***********************************************************************************************************
 * @file
 * mv_freq.sql
 *
 * Materialized View - frequency lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_freq;

CREATE MATERIALIZED VIEW ce_powerbi.mv_freq
AS
    SELECT
        pk_f,
        code  AS f_code,
        name  AS f_name,
        pk_f  AS f_order  -- ordering column
    FROM ce_warehouse.l_freq
    UNION ALL
    SELECT
        -1,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_freq
    IS 'Materialized View - frequency lookup';
