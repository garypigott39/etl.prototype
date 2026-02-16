/*
 ***********************************************************************************************************
 * @file
 * l_period.sql
 *
 * Lookup table - generated periods.
 * Assumes that the start of a period is always the first day of the period. WEEKLY periods start on a Monday.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_core.period;

CREATE TABLE IF NOT EXISTS ce_etl.l_period
(
    -- Pseudo index: see app code for details
    pk_p INT NOT NULL GENERATED ALWAYS
        AS (core.fx_ut_dt_to_pdi(p_start_of_period, p_freq)) STORED,
    p_freq INT NOT NULL REFERENCES ce_etl.l_freq (pk_f),  --NO action on update or delete, we will never change the frequency of a period once it's created
    p_start_of_period DATE NOT NULL,
    PRIMARY KEY (pk_p),
    UNIQUE (p_freq, p_start_of_period)
);

COMMENT ON TABLE ce_etl.l_period
    IS 'Lookup table - generated periods';
