/*
 ***********************************************************************************************************
 * @file
 * mv_period.sql
 *
 * Materialized View - period lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_period;

CREATE MATERIALIZED VIEW ce_powerbi.mv_period
AS
    SELECT
        p.pk_p,
        p.p_period,
        p.p_status,
        p.p_start_of_period,
        p.p_mid_of_period,
        p.p_end_of_period,
        p.p_days_in_period,
        -- Text version of frequency
        f.code  AS p_freq,
        p.p_period_name,
        p.p_decade_name
    FROM ce_warehouse.mv_period p
        LEFT JOIN ce_warehouse.l_freq f
            ON p.p_freq = f.pk_f

    UNION ALL

    SELECT
        -1,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_period
    IS 'Materialized View - period lookup.';
