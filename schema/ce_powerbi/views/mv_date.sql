/*
 ***********************************************************************************************************
 * @file
 * mv_date.sql
 *
 * View - "dimension" table for date lookup.
 *
 * Note, the string formatted date fields are causing an issue in PowerBi so using date instead.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_date;

CREATE MATERIALIZED VIEW ce_powerbi.mv_date
AS
    SELECT
        pk_d,
        d_date,
        d_status,
        d_decade,
        d_date  AS d_year,  -- Year is actually now a date, see CEP-23
        d_days_in_year,
        d_start_of_year,
        d_mid_of_year,
        d_end_of_year,
        d_quarter,
        d_days_in_quarter,
        d_start_of_quarter,
        d_mid_of_quarter,
        d_end_of_quarter,
        d_month,
        d_day_of_month,
        d_days_in_month,
        d_start_of_month,
        d_mid_of_month,
        d_end_of_month,
        d_week_number,
        d_start_of_week,
        d_mid_of_week,
        d_end_of_week,
        d_day_of_year,
        d_day_of_week,
        d_is_weekday,
        d_sequence_day,
        d_sequence_month,
        d_decade::TEXT ||'s'  AS d_decade_name,

        -- CEP-378: New columns
        d_year  AS d_yyyy_int,
        d_mmm_fy,
        d_mmmm_fy,
        d_month_fy,

        -- CEP-391: Fiscal year
        d_yyyy_fy,

        -- Calculated offset
        (d_date - CURRENT_DATE)::INT  AS d_offset,
        -- String representations will be done in PowerBi
        d_date  AS d_mmmm_yyyy_space,
        d_date  AS d_mmmm_yyyy_slash,
        d_date  AS d_mmmm_yyyy_dash,
        d_date  AS d_mmmm_yyyy_dot,

        d_date  AS d_mmmm_yy_space,
        d_date  AS d_mmmm_yy_slash,
        d_date  AS d_mmmm_yy_dash,
        d_date  AS d_mmmm_yy_dot,

        d_date  AS d_mmm_yyyy_space,
        d_date  AS d_mmm_yyyy_slash,
        d_date  AS d_mmm_yyyy_dash,
        d_date  AS d_mmm_yyyy_dot,

        d_date  AS d_mm_yyyy_space,
        d_date  AS d_mm_yyyy_slash,
        d_date  AS d_mm_yyyy_dash,
        d_date  AS d_mm_yyyy_dot,

        d_date  AS d_mmm_yy_space,
        d_date  AS d_mmm_yy_slash,
        d_date  AS d_mmm_yy_dash,
        d_date  AS d_mmm_yy_dot,

        d_date  AS d_mm_yy_space,
        d_date  AS d_mm_yy_slash,
        d_date  AS d_mm_yy_dash,
        d_date  AS d_mm_yy_dot,

        d_date  AS d_yy,
        d_date  AS d_mmmm,
        d_date  AS d_mmm
    FROM ce_powerbi.date
    UNION ALL
    SELECT
        -1,
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_date(),  -- Year is actually now a date, see CEP-23
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_bool(),
        0,
        0,
        NULL,

        -- CEP-378: New columns
        ce_powerbi.fx_ut_null_int(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int(),

        -- CEP-391: Fiscal year
        ce_powerbi.fx_ut_null_int(),

        -- Calculated offset
        (ce_powerbi.fx_ut_null_date() - CURRENT_DATE)::INT,

        -- String representations will be done in PowerBi
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),

        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date(),
        ce_powerbi.fx_ut_null_date()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_date
    IS 'Materialized View - date lookup';
