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
    period TEXT,
    -- p_status TEXT,  -- Dynamically update the status via the view
    start_of_period DATE,
    mid_of_period DATE,
    end_of_period DATE,
    days_in_period INT,
    freq INT GENERATED ALWAYS AS (pk_p / 100000000) STORED,  -- see ce_core.freq

    -- Period range, performance related. The "half-open" range "[)" may have a massive impact on
    -- the performance of the GIST index for date range queries; the closed range "[]" is more efficient but includes the
    -- first date of the next period so we would need to add in an additional condition in the queries to
    -- exclude that date. This is a known limitation of PostgreSQL range types when it comes to indexing and performance.

    -- The +1 trick is to ensure that the end date is exclusive in the range.
    date_range DATERANGE GENERATED ALWAYS AS (DATERANGE(start_of_period, end_of_period + 1, '[)')) STORED,

    -- String formats
    period_name TEXT,
    decade_name TEXT,

    -- Lag period number, frequency related
    lag INT,

    -- Pseudo index: e.g. 119000101 -> daily, 1900-01-01, see app code for details
    pk_p INT NOT NULL PRIMARY KEY
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_period__period
    ON ce_core.period (period);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS idx_period__date_range
    ON ce_core.period USING GIST (date_range);

COMMENT ON TABLE ce_core.period
    IS 'Lookup table - generated periods';
