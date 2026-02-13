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
    date DATE,

    -- status TEXT,  -- Dynamically update the status via the view

    -- Year
    decade INT,
    year INT,
    days_in_year INT,
    start_of_year DATE,
    mid_of_year DATE,
    end_of_year DATE,

    -- Quarter
    quarter INT,
    days_in_quarter INT,
    start_of_quarter DATE,
    mid_of_quarter DATE,
    end_of_quarter DATE,

    -- Month
    month INT,
    day_of_month INT,
    days_in_month INT,
    start_of_month DATE,
    mid_of_month DATE,
    end_of_month DATE,

    -- Week
    week_number INT,
    start_of_week DATE,
    mid_of_week DATE,
    end_of_week DATE,

    -- Day
    day_of_year INT,
    day_of_week INT,
    is_weekday BOOL,

    -- Day & month sequence
    sequence_day INT,
    sequence_month INT,

    -- CEP-378: New columns
    mmm_fy TEXT,  -- Jan, Feb, etc
    mmmm_fy TEXT,  -- January, February, etc
    month_fy INT,  -- Oct=1, Nov=2, etc

    -- CEP-391: Fiscal year
    yyyy_fy INT,

    -- Pseudo index: YYYYMMDD format primary key, see app code for details
    pk_d INT NOT NULL PRIMARY KEY
);

CREATE UNIQUE INDEX IF NOT EXISTS date__date_index
    ON ce_core.date (date);

COMMENT ON TABLE ce_core.date
    IS 'Lookup table - generated dates';
