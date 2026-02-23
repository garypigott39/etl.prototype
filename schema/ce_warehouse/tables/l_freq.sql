/*
 ***********************************************************************************************************
 * @file
 * l_freq.sql
 *
 * Lookup table - frequency lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_freq;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_freq
(
    pk_f SMALLINT NOT NULL GENERATED ALWAYS AS (
        CASE code
            WHEN 'D' THEN 1
            WHEN 'W' THEN 2
            WHEN 'M' THEN 3
            WHEN 'Q' THEN 4
            WHEN 'Y' THEN 5
        END
    ) STORED,

    code TEXT NOT NULL
        CHECK (code IN ('D', 'W', 'M', 'Q', 'Y')),  -- restrict to valid codes

    name TEXT NOT NULL GENERATED ALWAYS AS (
        CASE code
            WHEN 'D' THEN 'Daily'
            WHEN 'W' THEN 'Weekly'
            WHEN 'M' THEN 'Monthly'
            WHEN 'Q' THEN 'Quarterly'
            WHEN 'Y' THEN 'Yearly'
        END
    ) STORED,

    forecast_only_lifespan INT NOT NULL,

    PRIMARY KEY (pk_f),
    UNIQUE (code)
);

COMMENT ON TABLE ce_warehouse.l_freq
    IS 'Lookup table - frequency lookup';

/**
 * Pre-populate with known values. THIS WILL NEVER CHANGE!!!
 */
INSERT INTO ce_warehouse.l_freq (code, forecast_only_lifespan)
VALUES
    ('D', 1),
    ('W', 7),
    ('M', 30),
    ('Q', 90),
    ('Y', 365);
