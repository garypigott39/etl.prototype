/*
 ***********************************************************************************************************
 * @file
 * v_date.sql
 *
 * View - generated dates.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_core.v_date;

CREATE OR REPLACE VIEW ce_core.v_date AS
SELECT
    pk_d                                                                            AS pk_d,
    d_date                                                                          AS d_date,

    /* ================================================================
       YEAR
       ================================================================ */
    (EXTRACT(YEAR FROM d_date)::INT / 10) * 10                                      AS d_decade,
    EXTRACT(YEAR FROM d_date)::INT                                                  AS d_year,
    EXTRACT(DOY FROM (DATE_TRUNC('YEAR', d_date) + INTERVAL '1 YEAR - 1 DAY'))::INT AS d_days_in_year,
    DATE_TRUNC('YEAR', d_date)::DATE                                                AS d_start_of_year,
    (DATE_TRUNC('YEAR', d_date) + INTERVAL '6 MONTHS')::DATE                        AS d_mid_of_year,
    (DATE_TRUNC('YEAR', d_date) + INTERVAL '1 YEAR - 1 DAY')::DATE                  AS d_end_of_year,

    /* ================================================================
       QUARTER
       ================================================================ */
    EXTRACT(QUARTER FROM d_date)::INT                                               AS d_quarter,
    ((DATE_TRUNC('QUARTER', d_date) + INTERVAL '3 MONTHS - 1 DAY')::DATE
        - DATE_TRUNC('QUARTER', d_date)::date)::INT + 1                             AS d_days_in_quarter,
    DATE_TRUNC('QUARTER', d_date)::DATE                                             AS d_start_of_quarter,
    (DATE_TRUNC('QUARTER', d_date) + INTERVAL '45 DAYS')::DATE                      AS d_mid_of_quarter,
    (DATE_TRUNC('QUARTER', d_date) + INTERVAL '3 MONTHS - 1 DAY')::DATE             AS d_end_of_quarter,

    /* ================================================================
       MONTH
       ================================================================ */
    EXTRACT(MONTH FROM d_date)::INT                                                 AS d_month,
    EXTRACT(DAY FROM d_date)::INT                                                   AS d_day_of_month,
    EXTRACT(DAY FROM (DATE_TRUNC('MONTH', d_date) + INTERVAL '1 MONTH - 1 DAY'))::INT AS d_days_in_month,
    DATE_TRUNC('MONTH', d_date)::DATE                                               AS d_start_of_month,
    (DATE_TRUNC('MONTH', d_date) + INTERVAL '14 DAYS')::DATE                        AS d_mid_of_month,
    (DATE_TRUNC('MONTH', d_date) + INTERVAL '1 MONTH - 1 DAY')::DATE                AS d_end_of_month,

    /* ================================================================
       WEEK (ISO)
       ================================================================ */
    EXTRACT(WEEK FROM d_date)::INT                                                  AS d_week_number,
    DATE_TRUNC('WEEK', d_date)::DATE                                                AS d_start_of_week,
    (DATE_TRUNC('WEEK', d_date) + INTERVAL '3 DAYS')::DATE                          AS d_mid_of_week,
    (DATE_TRUNC('WEEK', d_date) + INTERVAL '6 DAYS')::DATE                          AS d_end_of_week,

    /* ================================================================
       DAY
       ================================================================ */
    EXTRACT(DOY FROM d_date)::INT                                                   AS d_day_of_year,
    EXTRACT(ISODOW FROM d_date)::INT                                                AS d_day_of_week,
    (EXTRACT(ISODOW FROM d_date) BETWEEN 1 AND 5)                                   AS d_is_weekday,

    /* ================================================================
       SEQUENCES
       ================================================================ */
    (d_date - DATE '1900-01-01')::INT                                               AS d_sequence_day,
    (EXTRACT(YEAR FROM d_date)::INT * 12 + EXTRACT(MONTH FROM d_date)::INT)         AS d_sequence_month,

    /* ================================================================
       FISCAL (OCT = 1)
       ================================================================ */
    TO_CHAR(d_date, 'Mon')                                                          AS d_mmm_fy,
    TO_CHAR(d_date, 'FMmonth')                                                      AS d_mmmm_fy,
    ((EXTRACT(MONTH FROM d_date)::INT + 2) % 12) + 1                                AS d_month_fy,
    CASE
        WHEN EXTRACT(MONTH FROM d_date) >= 10 THEN EXTRACT(YEAR FROM d_date)::INT + 1
        ELSE EXTRACT(YEAR FROM d_date)::INT
    END                                                                             AS d_yyyy_fy

FROM ce_core.date d;

COMMENT ON VIEW ce_core.v_date
    IS 'View - generated dates';
