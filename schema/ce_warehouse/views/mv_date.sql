/*
 ***********************************************************************************************************
 * @file
 * mv_date.sql
 *
 * Materialized View - generated dates.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv_date;

CREATE MATERIALIZED VIEW ce_warehouse.mv_date
AS
WITH _range AS (
    SELECT
        min.value::DATE                      AS dt1,
        CURRENT_DATE + (max.value::INTERVAL) AS dt2
    FROM ce_warehouse.s_sys_flags min
        CROSS JOIN ce_warehouse.s_sys_flags max
    WHERE min.code = 'DATE.MIN'
    AND max.code = 'DATE.MAX'
),
_dates AS (
    SELECT
        generate_series(dt1, dt2, INTERVAL '1 DAY')::DATE AS dt
    FROM _range
)
SELECT
    ce_warehouse.fx_ut_date_to_dti(d.dt)::INT                                       AS pk_d,
    d.dt                                                                            AS date,

    -- Status (Past, Current, Future)
    CASE
        WHEN d.dt < CURRENT_DATE THEN 'Past'
        WHEN d.dt > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END                                                                             AS status,

    /* ================================================================
       YEAR
       ================================================================ */
    (EXTRACT(YEAR FROM d.dt)::INT / 10) * 10                                        AS decade,
    EXTRACT(YEAR FROM d.dt)::INT                                                    AS year,
    EXTRACT(DOY FROM (DATE_TRUNC('YEAR', d.dt) + INTERVAL '1 YEAR - 1 DAY'))::INT   AS days_in_year,
    DATE_TRUNC('YEAR', d.dt)::DATE                                                  AS start_of_year,
    (DATE_TRUNC('YEAR', d.dt) + INTERVAL '6 MONTHS')::DATE                          AS mid_of_year,
    (DATE_TRUNC('YEAR', d.dt) + INTERVAL '1 YEAR - 1 DAY')::DATE                    AS end_of_year,

    /* ================================================================
       QUARTER
       ================================================================ */
    EXTRACT(QUARTER FROM d.dt)::INT                                                 AS quarter,
    ((DATE_TRUNC('QUARTER', d.dt) + INTERVAL '3 MONTHS - 1 DAY')::DATE
        - DATE_TRUNC('QUARTER', d.dt)::date)::INT + 1                               AS days_in_quarter,
    DATE_TRUNC('QUARTER', d.dt)::DATE                                               AS start_of_quarter,
    (DATE_TRUNC('QUARTER', d.dt) + INTERVAL '45 DAYS')::DATE                        AS mid_of_quarter,
    (DATE_TRUNC('QUARTER', d.dt) + INTERVAL '3 MONTHS - 1 DAY')::DATE               AS end_of_quarter,

    /* ================================================================
       MONTH
       ================================================================ */
    EXTRACT(MONTH FROM d.dt)::INT                                                   AS month,
    EXTRACT(DAY FROM d.dt)::INT                                                     AS day_of_month,
    EXTRACT(DAY FROM (DATE_TRUNC('MONTH', d.dt) + INTERVAL '1 MONTH - 1 DAY'))::INT AS days_in_month,
    DATE_TRUNC('MONTH', d.dt)::DATE                                                 AS start_of_month,
    (DATE_TRUNC('MONTH', d.dt) + INTERVAL '14 DAYS')::DATE                          AS mid_of_month,
    (DATE_TRUNC('MONTH', d.dt) + INTERVAL '1 MONTH - 1 DAY')::DATE                  AS end_of_month,

    /* ================================================================
       WEEK (ISO)
       ================================================================ */
    EXTRACT(WEEK FROM d.dt)::INT                                                    AS week_number,
    DATE_TRUNC('WEEK', d.dt)::DATE                                                  AS start_of_week,
    (DATE_TRUNC('WEEK', d.dt) + INTERVAL '3 DAYS')::DATE                            AS mid_of_week,
    (DATE_TRUNC('WEEK', d.dt) + INTERVAL '6 DAYS')::DATE                            AS end_of_week,

    /* ================================================================
       DAY
       ================================================================ */
    EXTRACT(DOY FROM d.dt)::INT                                                     AS day_of_year,
    EXTRACT(ISODOW FROM d.dt)::INT                                                  AS day_of_week,
    (EXTRACT(ISODOW FROM d.dt) BETWEEN 1 AND 5)                                     AS is_weekday,

    /* ================================================================
       SEQUENCES
       ================================================================ */
    (d.dt - DATE '1900-01-01')::INT                                                 AS sequence_day,
    (EXTRACT(YEAR FROM d.dt)::INT * 12 + EXTRACT(MONTH FROM d.dt)::INT)             AS sequence_month,

    /* ================================================================
       FISCAL (OCT = 1)
       ================================================================ */
    TO_CHAR(d.dt, 'Mon')                                                            AS mmm_fy,
    TO_CHAR(d.dt, 'FMmonth')                                                        AS mmmm_fy,
    ((EXTRACT(MONTH FROM d.dt)::INT + 2) % 12) + 1                                  AS month_fy,
    CASE
        WHEN EXTRACT(MONTH FROM d.dt) >= 10 THEN EXTRACT(YEAR FROM d.dt)::INT + 1
        ELSE EXTRACT(YEAR FROM d.dt)::INT
    END                                                                             AS yyyy_fy

FROM _dates d;

CREATE UNIQUE INDEX IF NOT EXISTS mv_date__pk_d__idx
    ON ce_warehouse.mv_date (pk_d);

CREATE UNIQUE INDEX IF NOT EXISTS mv_date__date__idx
    ON ce_warehouse.mv_date (date);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv_date
    IS 'Materialized View - generated dates';
