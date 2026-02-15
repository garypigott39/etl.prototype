/*
 ***********************************************************************************************************
 * @file
 * mv_period.sql
 *
 * MaterialiZed View - generated periods.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS core.mv_period;

CREATE MATERIALIZED VIEW IF NOT EXISTS core.mv_period
WITH _base AS (

)
SELECT
    id                                                                     AS pk_p,

    p_period,
    p_freq,
    p_start_of_period,
    (p_start_of_period + ((p_end_of_period - p_start_of_period)/2))::DATE  AS p_mid_of_period,
    p_end_of_period,
    (p_end_of_period - p_start_of_period + 1)::INT                         AS p_days_in_period,
    p_date_range,

    CASE
        WHEN p_freq = 1 THEN TO_CHAR(p_start_of_period, 'DD/MM/YYYY')
        WHEN p_freq = 2 THEN 'w' || TO_CHAR(p_start_of_period, 'IW IYYY')
        WHEN p_freq = 3 THEN TO_CHAR(p_start_of_period, 'MM YYYY')
        WHEN p_freq = 4 THEN 'Q' || TO_CHAR(p_start_of_period, 'Q YYYY')
        WHEN p_freq = 5 THEN TO_CHAR(p_start_of_period, 'YYYY')
    END                                                                    AS p_period_name,

    SUBSTR(EXTRACT(YEAR FROM p_start_of_period)::text, 1, 3) || '0s'       AS p_decade_name

    -- Status
    CASE
        WHEN p_end_of_period < CURRENT_DATE THEN 'Past'
        WHEN p_start_of_period > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END                                                                    AS p_status,

    -- Lag period number, frequency related
    p_lag

FROM core.l_period;

COMMENT ON VIEW ce_core.v_period
    IS 'View - generated periods';



    p_mid_of_period DATE,
    p_end_of_period DATE,
    p_days_in_period INT,
    p_freq INT GENERATED ALWAYS AS (id / 100000000) STORED,  -- see ce_core.freq

    -- Period range, performance related. The "half-open" range "[)" may have a massive impact on
    -- the performance of the GIST index for date range queries; the closed range "[]" is more efficient but includes the
    -- first date of the next period so we would need to add in an additional condition in the queries to
    -- exclude that date. This is a known limitation of PostgreSQL range types when it comes to indexing and performance.

    -- The +1 trick is to ensure that the end date is exclusive in the range.
    p_date_range DATERANGE GENERATED ALWAYS AS (DATERANGE(p_start_of_period, p_end_of_period + 1, '[)')) STORED,

    -- String formats
    p_period_name TEXT,
    p_decade_name TEXT,

    -- Lag period number, frequency related
    p_lag INT,

    PRIMARY KEY (id),
    UNIQUE (p_period)
);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS l_period__p_date_range
    ON core.l_period USING GIST (p_date_range);
