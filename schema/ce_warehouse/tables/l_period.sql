/*
 ***********************************************************************************************************
 * @file
 * l_period.sql
 *
 * Lookup table - period lookup. System generated.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_period;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_period
(
    pk_pdi INT NOT NULL GENERATED ALWAYS
        AS (ce_warehouse.fx_ut__date_to_pdi_or_dti(start_of_period, ifreq)) STORED,

    ifreq SMALLINT NOT NULL
        CHECK (ifreq IN (1, 2, 3, 4, 5)), -- 1=DAILY, 2=WEEKLY, 3=MONTHLY, 4=QUARTERLY, 5=YEARLY
    start_of_period DATE NOT NULL
        CHECK (ce_warehouse.fx_val__is_start_date(start_of_period, ifreq) IS NULL),

    end_of_period DATE NOT NULL,  -- Calculated on the way in, as used in GENERATED columns below

    period TEXT NOT NULL,  -- Calculated on the way in, avoids the IMMUTABLE issue!!

    lag INT NOT NULL,  -- Calculated on the way in

    -- Period range, performance related. The "half-open" range "[)" may have a massive impact on
    -- the performance of the GIST index for date range queries; the closed range "[]" is more efficient but includes the
    -- first date of the next period so we would need to add in an additional condition in the queries to
    -- exclude that date. This is a known limitation of PostgreSQL range types when it comes to indexing and performance.

    -- The +1 trick is to ensure that the end date is exclusive in the range.
    date_range DATERANGE GENERATED ALWAYS
        AS (DATERANGE(start_of_period, end_of_period + 1, '[)')) STORED,

    PRIMARY KEY (pk_pdi),
    UNIQUE (ifreq, start_of_period)
);

COMMENT ON TABLE ce_warehouse.l_period
    IS 'Lookup table - period lookup. System generated';
