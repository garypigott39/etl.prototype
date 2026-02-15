/*
 ***********************************************************************************************************
 * @file
 * l_freq.sql
 *
 * Lookup table - frequency lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_etl.l_freq;

CREATE TABLE IF NOT EXISTS ce_etl.l_freq
(
    id INT
    code TEXT NOT NULL CHECK (code ~ '^[DWMQY]$'), -- Single uppercase letter
    name TEXT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (code)
);

COMMENT ON TABLE ce_etl.l_freq
    IS 'Lookup table - frequency lookup';

/**
 * Pre-populate with known values. THIS WILL NEVER CHANGE!!!
 */
INSERT INTO ce_etl.freq
VALUES
(1, 'D', 'Daily'),
(2, 'W', 'Weekly'),
(3, 'M', 'Monthly'),
(4, 'Q', 'Quarterly'),
(5, 'Y','Yearly');
