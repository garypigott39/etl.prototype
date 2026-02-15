/*
 ***********************************************************************************************************
 * @file
 * l_date.sql
 *
 * Lookup table - generated dates.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS core.l_date;

CREATE TABLE IF NOT EXISTS core.l_date
(
    -- Pseudo index: see app code for details
    id INT GENERATED ALWAYS AS (core.fx_ut_dt_to_dti(d_date)) STORED,

    d_date DATE NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (d_date)
);

COMMENT ON TABLE core.l_date
    IS 'Lookup table - generated dates';
