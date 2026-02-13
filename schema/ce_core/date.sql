/*
 ***********************************************************************************************************
 * @file
 * date.sql
 *
 * Lookup table - generated dates.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_core.date;

CREATE TABLE IF NOT EXISTS ce_core.date
(
    -- Pseudo index: YYYYMMDD format primary key, see app code for details
    pk_d INT GENERATED ALWAYS AS (
        EXTRACT(YEAR FROM d_date) * 10000 +
        EXTRACT(MONTH FROM d_date) * 100 +
        EXTRACT(DAY FROM d_date)) STORED,
    d_date DATE NOT NULL,
    PRIMARY KEY (pk_d),
    UNIQUE (d_date)
);

COMMENT ON TABLE ce_core.date
    IS 'Lookup table - generated dates';
