/*
 ***********************************************************************************************************
 * @file
 * v_period.sql
 *
 * View - period lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.v_period;

CREATE OR REPLACE VIEW ce_powerbi.v_period
AS
    SELECT
        pk_p                 AS pk_p,  -- use the surrogate key from base mv_period!!
        period               AS p_period,
        status               AS p_status,
        start_of_period      AS p_start_of_period,
        mid_of_period        AS p_mid_of_period,
        end_of_period        AS p_end_of_period,
        days_in_period       AS p_days_in_period,
        freq_code            AS p_freq,
        period_name          AS p_period_name,
        decade_name          AS p_decade_name
    FROM ce_warehouse.mv_period

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
        ce_powerbi.fx_ut_null_text();

COMMENT ON VIEW ce_powerbi.v_period
    IS 'View - period lookup.';
