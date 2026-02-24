/*
 ***********************************************************************************************************
 * @file
 * v_date.sql
 *
 * View - generated dates metadata.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_warehouse.v_date;

CREATE OR REPLACE VIEW ce_warehouse.v_date
AS
SELECT
    d.pk_dti                                                                          AS pk_dti,
    d.date                                                                            AS date,

    -- Status (Past, Current, Future)
    CASE
        WHEN d.date < CURRENT_DATE THEN 'Past'
        WHEN d.date > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END                                                                               AS status,

    /* ================================================================
       YEAR
       ================================================================ */
    (EXTRACT(YEAR FROM d.date)::INT / 10) * 10                                        AS decade,
    EXTRACT(YEAR FROM d.date)::INT                                                    AS year,
    EXTRACT(DOY FROM (DATE_TRUNC('YEAR', d.date) + INTERVAL '1 YEAR - 1 DAY'))::INT   AS days_in_year,
    DATE_TRUNC('YEAR', d.date)::DATE                                                  AS start_of_year,
    (DATE_TRUNC('YEAR', d.date) + INTERVAL '6 MONTHS')::DATE                          AS mid_of_year,
    (DATE_TRUNC('YEAR', d.date) + INTERVAL '1 YEAR - 1 DAY')::DATE                    AS end_of_year,

    /* ================================================================
       QUARTER
       ================================================================ */
    EXTRACT(QUARTER FROM d.date)::INT                                                 AS quarter,
    ((DATE_TRUNC('QUARTER', d.date) + INTERVAL '3 MONTHS - 1 DAY')::DATE
        - DATE_TRUNC('QUARTER', d.date)::date)::INT + 1                               AS days_in_quarter,
    DATE_TRUNC('QUARTER', d.date)::DATE                                               AS start_of_quarter,
    (DATE_TRUNC('QUARTER', d.date) + INTERVAL '45 DAYS')::DATE                        AS mid_of_quarter,
    (DATE_TRUNC('QUARTER', d.date) + INTERVAL '3 MONTHS - 1 DAY')::DATE               AS end_of_quarter,

    /* ================================================================
       MONTH
       ================================================================ */
    EXTRACT(MONTH FROM d.date)::INT                                                   AS month,
    EXTRACT(DAY FROM d.date)::INT                                                     AS day_of_month,
    EXTRACT(DAY FROM (DATE_TRUNC('MONTH', d.date) + INTERVAL '1 MONTH - 1 DAY'))::INT AS days_in_month,
    DATE_TRUNC('MONTH', d.date)::DATE                                                 AS start_of_month,
    (DATE_TRUNC('MONTH', d.date) + INTERVAL '14 DAYS')::DATE                          AS mid_of_month,
    (DATE_TRUNC('MONTH', d.date) + INTERVAL '1 MONTH - 1 DAY')::DATE                  AS end_of_month,

    /* ================================================================
       WEEK (ISO)
       ================================================================ */
    EXTRACT(WEEK FROM d.date)::INT                                                    AS week_number,
    DATE_TRUNC('WEEK', d.date)::DATE                                                  AS start_of_week,
    (DATE_TRUNC('WEEK', d.date) + INTERVAL '3 DAYS')::DATE                            AS mid_of_week,
    (DATE_TRUNC('WEEK', d.date) + INTERVAL '6 DAYS')::DATE                            AS end_of_week,

    /* ================================================================
       DAY
       ================================================================ */
    EXTRACT(DOY FROM d.date)::INT                                                     AS day_of_year,
    EXTRACT(ISODOW FROM d.date)::INT                                                  AS day_of_week,
    (EXTRACT(ISODOW FROM d.date) BETWEEN 1 AND 5)                                     AS is_weekday,

    /* ================================================================
       SEQUENCES
       ================================================================ */
    (d.date - s.value::DATE)::INT  + 1                                                AS sequence_day,
    (
        (EXTRACT(YEAR FROM AGE(d.date, s.value::DATE)) * 12) +
        EXTRACT(MONTH FROM AGE(d.date, s.value::DATE)) + 1
    )                                                                              AS sequence_month,

    /* ================================================================
       FISCAL (OCT = 1)
       ================================================================ */
    TO_CHAR(d.date, 'Mon')                                                            AS mmm_fy,
    TO_CHAR(d.date, 'FMmonth')                                                        AS mmmm_fy,
    ((EXTRACT(MONTH FROM d.date)::INT + 2) % 12) + 1                                  AS month_fy,
    CASE
        WHEN EXTRACT(MONTH FROM d.date) >= 10 THEN EXTRACT(YEAR FROM d.date)::INT + 1
        ELSE EXTRACT(YEAR FROM d.date)::INT
    END                                                                               AS yyyy_fy

FROM ce_warehouse.l_date d
    JOIN ce_warehouse.s_sys_flags s
        ON s.code = 'DATE.MIN';

COMMENT ON VIEW ce_warehouse.v_date
    IS 'View - generated dates metadata';
