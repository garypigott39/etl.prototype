/*
 ***********************************************************************************************************
 * @file
 * period.sql
 *
 * Lookup table - generated periods.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_core.period;

CREATE TABLE IF NOT EXISTS ce_core.period
(
    pk_p INT,

    p_period TEXT,
    p_start_of_period DATE,
    p_mid_of_period DATE,
    p_end_of_period DATE,
    p_days_in_period INT,
    p_freq INT GENERATED ALWAYS AS (pk_p / 100000000) STORED,  -- see ce_core.freq

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

    PRIMARY KEY (pk_p),
    UNIQUE (p_period)
);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS period__p_date_range
    ON ce_core.period USING GIST (p_date_range);

COMMENT ON TABLE ce_core.period
    IS 'Lookup table - generated periods';
