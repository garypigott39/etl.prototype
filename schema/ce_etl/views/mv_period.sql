/*
 ***********************************************************************************************************
 * @file
 * mv_period.sql
 *
 * Materialized View - generated periods.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_etl.mv_period;

CREATE MATERIALIZED VIEW IF NOT EXISTS ce_etl.mv_period
AS
WITH _base AS (
    SELECT
        pk_p,
        p_freq,
        p_start_of_period,
        CASE
            WHEN p_freq = 1 THEN 1
            WHEN p_freq = 2 THEN 7
            WHEN p_freq = 3 THEN
                (p_start_of_period + INTERVAL '1 MONTH' - INTERVAL '1 DAY')::DATE - p_start_of_period + 1
            WHEN p_freq = 4 THEN
                (p_start_of_period + INTERVAL '3 MONTHS' - INTERVAL '1 DAY')::DATE - p_start_of_period + 1
            WHEN p_freq = 5 THEN
                (p_start_of_period + INTERVAL '1 YEAR' - INTERVAL '1 DAY')::DATE - p_start_of_period + 1
        END AS p_days_in_period,
        CASE
            WHEN p_freq = 1 THEN TO_CHAR(p_start_of_period, 'YYYY-MM-DD')
            WHEN p_freq = 2 THEN 'w' || TO_CHAR(p_start_of_period, 'IYYY-\WIW')
            WHEN p_freq = 3 THEN TO_CHAR(p_start_of_period, 'YYYY-MM')
            WHEN p_freq = 4 THEN 'Q' || TO_CHAR(p_start_of_period, 'YYYY-\QQ')
            WHEN p_freq = 5 THEN TO_CHAR(p_start_of_period, 'YYYY')
        END AS p_period,
        CASE
            WHEN p_freq = 1 THEN TO_CHAR(p_start_of_period, 'DD/MM/YYYY')
            WHEN p_freq = 2 THEN 'w' || TO_CHAR(p_start_of_period, 'IYYYIW')
            WHEN p_freq = 3 THEN TO_CHAR(p_start_of_period, 'MM YYYY')
            WHEN p_freq = 4 THEN 'Q' || TO_CHAR(p_start_of_period, 'Q YYYY')
            WHEN p_freq = 5 THEN TO_CHAR(p_start_of_period, 'YYYY')
        END AS p_period_name,
        SUBSTR(EXTRACT(YEAR FROM p_start_of_period)::TEXT, 1, 3) || '0s' AS p_decade_name

    FROM ce_etl.l_period
),
_lag  AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY p_freq
            ORDER BY p_start_of_period
        ) AS p_lag
    FROM _base
),
_final AS (
    SELECT
       *,
       (p_start_of_period + ((p_days_in_period - 1) / 2))::DATE AS p_mid_of_period,
       (p_start_of_period + p_days_in_period - 1)::DATE AS p_end_of_period
    FROM _lag
)
SELECT
    pk_p,
    p_period,
    p_start_of_period,
    p_mid_of_period,
    p_end_of_period,
    p_days_in_period,
    p_freq,

    -- Period range, performance related. The "half-open" range "[)" may have a massive impact on
    -- the performance of the GIST index for date range queries; the closed range "[]" is more efficient but includes the
    -- first date of the next period so we would need to add in an additional condition in the queries to
    -- exclude that date. This is a known limitation of PostgreSQL range types when it comes to indexing and performance.

    -- The +1 trick is to ensure that the end date is exclusive in the range.
    DATERANGE(p_start_of_period, p_end_of_period + 1, '[)') AS p_date_range,

    p_period_name,
    p_decade_name,
    CASE
        WHEN p_end_of_period < CURRENT_DATE THEN 'Past'
        WHEN p_start_of_period > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END AS p_status,
    p_lag

FROM _final;

CREATE UNIQUE INDEX mv_period__pk_p__idx
    ON ce_etl.mv_period(pk_p);

CREATE UNIQUE INDEX mv_period__period__idx
    ON ce_etl.mv_period(p_period);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS mv_period__date_range__idx
    ON ce_etl.mv_period USING GIST (p_date_range);

COMMENT ON MATERIALIZED VIEW ce_etl.mv_period
    IS 'Materialized View - generated periods';
