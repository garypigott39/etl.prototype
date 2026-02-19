/*
 ***********************************************************************************************************
 * @file
 * v_date.sql
 *
 * View - "dimension" table for date lookup.
 *
 * Note, the string formatted date fields are causing an issue in PowerBi so using date instead.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.v_date;

CREATE OR REPLACE VIEW ce_powerbi.v_date
AS
    SELECT
        d.pk_d,
        d.date                        AS d_date,
        d.status                      AS d_status,
        d.decade                      AS d_decade,
        d.date                        AS d_year,  -- Year is actually now a date, see CEP-23
        d.days_in_year                AS d_days_in_year,
        d.start_of_year               AS d_start_of_year,
        d.mid_of_year                 AS d_mid_of_year,
        d.end_of_year                 AS d_end_of_year,
        d.quarter                     AS d_quarter,
        d.days_in_quarter             AS d_days_in_quarter,
        d.start_of_quarter            AS d_start_of_quarter,
        d.mid_of_quarter              AS d_mid_of_quarter,
        d.end_of_quarter              AS d_end_of_quarter,
        d.month                       AS d_month,
        d.day_of_month                AS d_day_of_month,
        d.days_in_month               AS d_days_in_month,
        d.start_of_month              AS d_start_of_month,
        d.mid_of_month                AS d_mid_of_month,
        d.end_of_month                AS d_end_of_month,
        d.week_number                 AS d_week_number,
        d.start_of_week               AS d_start_of_week,
        d.mid_of_week                 AS d_mid_of_week,
        d.end_of_week                 AS d_end_of_week,
        d.day_of_year                 AS d_day_of_year,
        d.day_of_week                 AS d_day_of_week,
        d.is_weekday                  AS d_is_weekday,
        d.sequence_day                AS d_sequence_day,
        d.sequence_month              AS d_sequence_month,
        d.decade::TEXT ||'s'          AS d_decade_name,

        -- CEP-378: New columns
        d.year                        AS d_yyyy_int,
        d.mmm_fy                      AS d_mmm_fy,
        d.mmmm_fy                     AS d_mmmm_fy,
        d.month_fy                    AS d_month_fy,

        -- CEP-391: Fiscal year
        d.yyyy_fy                     AS d_yyyy_fy,

        -- Calculated offset
        (d.date - CURRENT_DATE)::INT  AS d_offset,
        -- String representations will be done in PowerBi
        d.date                        AS d_mmmm_yyyy_space,
        d.date                        AS d_mmmm_yyyy_slash,
        d.date                        AS d_mmmm_yyyy_dash,
        d.date                        AS d_mmmm_yyyy_dot,

        d.date                        AS d_mmmm_yy_space,
        d.date                        AS d_mmmm_yy_slash,
        d.date                        AS d_mmmm_yy_dash,
        d.date                        AS d_mmmm_yy_dot,

        d.date                        AS d_mmm_yyyy_space,
        d.date                        AS d_mmm_yyyy_slash,
        d.date                        AS d_mmm_yyyy_dash,
        d.date                        AS d_mmm_yyyy_dot,

        d.date                        AS d_mm_yyyy_space,
        d.date                        AS d_mm_yyyy_slash,
        d.date                        AS d_mm_yyyy_dash,
        d.date                        AS d_mm_yyyy_dot,

        d.date                        AS d_mmm_yy_space,
        d.date                        AS d_mmm_yy_slash,
        d.date                        AS d_mmm_yy_dash,
        d.date                        AS d_mmm_yy_dot,

        d.date                        AS d_mm_yy_space,
        d.date                        AS d_mm_yy_slash,
        d.date                        AS d_mm_yy_dash,
        d.date                        AS d_mm_yy_dot,

        d.date                        AS d_yy,
        d.date                        AS d_mmmm,
        d.date                        AS d_mmm
    FROM ce_warehouse.mv_date d

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

COMMENT ON VIEW ce_powerbi.v_date
    IS 'View - date lookup';
