/*
 ***********************************************************************************************************
 * @file
 * l_period.sql
 *
 * Lookup table - generated periods.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_core.period;

CREATE TABLE IF NOT EXISTS core.l_period
(
    -- Pseudo index: see app code for details
    id INT GENERATED ALWAYS AS (core.fx_ut_dt_to_pdi(p_start_of_period, p_freq)) STORED,

    p_start_of_period DATE NOT NULL,
    p_freq INT NOT NULL REFERENCES core.l_freq (id),  --NO action on update or delete, we will never change the frequency of a period once it's created

    PRIMARY KEY (id),
    UNIQUE (p_start_of_period, p_freq)
);

COMMENT ON TABLE core.l_period
    IS 'Lookup table - generated periods';
