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
    pk_f SMALLINT NOT NULL,

    code TEXT NOT NULL
        CHECK (code IN ('D', 'W', 'M', 'Q', 'Y')),  -- restrict to valid codes
    name TEXT NOT NULL,

    forecast_only_lifespan INT NOT NULL,

    PRIMARY KEY (pk_f),
    UNIQUE (code)
);

COMMENT ON TABLE ce_warehouse.l_freq
    IS 'Lookup table - frequency lookup';

/**
 * Pre-populate with known values. THIS WILL NEVER CHANGE!!!
 */
INSERT INTO ce_warehouse.l_freq
VALUES
    (1, 'D', 'Daily', 1),
    (2, 'W', 'Weekly', 7),
    (3, 'M', 'Monthly', 30),
    (4, 'Q', 'Quarterly', 90),
    (5, 'Y','Yearly', 365);
