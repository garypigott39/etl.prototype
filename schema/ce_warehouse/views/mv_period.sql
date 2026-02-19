/*
 ***********************************************************************************************************
 * @file
 * mv_period.sql
 *
 * Materialized View - generated periods.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv_period;

CREATE MATERIALIZED VIEW IF NOT EXISTS ce_warehouse.mv_period
AS
WITH _periods AS (
    -- DAILY
    SELECT
        ce_warehouse.fx_ut_date_to_pdi(d.date, 1) AS pk_p,
        1 AS freq,
        d.date AS start_of_period
    FROM ce_warehouse.mv_date d

    UNION ALL

    -- WEEKLY
    SELECT
        ce_warehouse.fx_ut_date_to_pdi(d.start_of_week, 2) AS pk_p,
        2 AS freq,
        d.start_of_week AS start_of_period
    FROM (
        SELECT DISTINCT start_of_week FROM ce_warehouse.mv_date
    ) d

    UNION ALL

    -- MONTHLY
    SELECT
        ce_warehouse.fx_ut_date_to_pdi(d.start_of_month, 3) AS pk_p,
        3 AS freq,
        d.start_of_month AS start_of_period
    FROM (
        SELECT DISTINCT start_of_month FROM ce_warehouse.mv_date
    ) d

    UNION ALL

    -- QUARTERLY
    SELECT
        ce_warehouse.fx_ut_date_to_pdi(d.start_of_quarter, 4) AS pk_p,
        4 AS freq,
        d.start_of_quarter AS start_of_period
    FROM (
        SELECT DISTINCT start_of_quarter FROM ce_warehouse.mv_date
    ) d

    UNION ALL

    -- YEARLY
    SELECT
        ce_warehouse.fx_ut_date_to_pdi(d.start_of_year, 5) AS pk_p,
        5 AS freq,
        d.start_of_year AS start_of_period
    FROM (
        SELECT DISTINCT start_of_year FROM ce_warehouse.mv_date
    ) d
),
_base AS (
    SELECT
        pk_p,
        freq,
        start_of_period,
        CASE
            WHEN freq = 1 THEN 1
            WHEN freq = 2 THEN 7
            WHEN freq = 3 THEN
                (start_of_period + INTERVAL '1 MONTH' - INTERVAL '1 DAY')::DATE - start_of_period + 1
            WHEN freq = 4 THEN
                (start_of_period + INTERVAL '3 MONTHS' - INTERVAL '1 DAY')::DATE - start_of_period + 1
            WHEN freq = 5 THEN
                (start_of_period + INTERVAL '1 YEAR' - INTERVAL '1 DAY')::DATE - start_of_period + 1
        END AS days_in_period,
        CASE
            WHEN freq = 1 THEN TO_CHAR(start_of_period, 'YYYY-MM-DD')
            WHEN freq = 2 THEN TO_CHAR(start_of_period, 'IYYY-"W"IW')
            WHEN freq = 3 THEN TO_CHAR(start_of_period, 'YYYY-MM')
            WHEN freq = 4 THEN TO_CHAR(start_of_period, 'YYYY-"Q"Q')
            WHEN freq = 5 THEN TO_CHAR(start_of_period, 'YYYY')
        END AS period,
        CASE
            WHEN freq = 1 THEN TO_CHAR(start_of_period, 'DD/MM/YYYY')
            WHEN freq = 2 THEN 'w' || TO_CHAR(start_of_period, 'IW IYYY')
            WHEN freq = 3 THEN TO_CHAR(start_of_period, 'MM YYYY')
            WHEN freq = 4 THEN 'Q' || TO_CHAR(start_of_period, 'Q YYYY')
            WHEN freq = 5 THEN TO_CHAR(start_of_period, 'YYYY')
        END AS period_name,
        SUBSTR(EXTRACT(YEAR FROM start_of_period)::TEXT, 1, 3) || '0s' AS decade_name

    FROM _periods
),
_lag  AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY freq
            ORDER BY start_of_period
        ) AS lag
    FROM _base
),
_final AS (
    SELECT
       *,
       (start_of_period + ((days_in_period - 1) / 2))::DATE AS mid_of_period,
       (start_of_period + days_in_period - 1)::DATE AS end_of_period
    FROM _lag
)
SELECT
    p.pk_p,
    p.period,
    p.start_of_period,
    p.mid_of_period,
    p.end_of_period,
    p.days_in_period,
    p.freq,
    f.code AS freq_code,

    -- Period range, performance related. The "half-open" range "[)" may have a massive impact on
    -- the performance of the GIST index for date range queries; the closed range "[]" is more efficient but includes the
    -- first date of the next period so we would need to add in an additional condition in the queries to
    -- exclude that date. This is a known limitation of PostgreSQL range types when it comes to indexing and performance.

    -- The +1 trick is to ensure that the end date is exclusive in the range.
    DATERANGE(p.start_of_period, p.end_of_period + 1, '[)') AS date_range,

    p.period_name,
    p.decade_name,
    CASE
        WHEN p.end_of_period < CURRENT_DATE THEN 'Past'
        WHEN p.start_of_period > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END AS status,
    p.lag

FROM _final p
    LEFT JOIN ce_warehouse.l_freq f
        ON p.freq = f.pk_f;

CREATE UNIQUE INDEX mv_period__pk__idx
    ON ce_warehouse.mv_period(pk_p);

CREATE UNIQUE INDEX mv_period__period__idx
    ON ce_warehouse.mv_period(period);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS mv_period__date_range__idx
    ON ce_warehouse.mv_period USING GIST (date_range);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv_period
    IS 'Materialized View - generated periods';
