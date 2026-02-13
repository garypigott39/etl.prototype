/*
 ***********************************************************************************************************
 * @file
 * period.sql
 *
 * View - generated periods.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_core.period;

CREATE VIEW IF NOT EXISTS ce_core.v_period
WITH _base AS (

)
SELECT
    pk_p,

    p_period,
    p_freq,
    p_start_of_period,
    (p_start_of_period + ((p_end_of_period - p_start_of_period)/2))::DATE  AS p_mid_of_period,
    p_end_of_period,
    (p_end_of_period - p_start_of_period + 1)::INT                         AS p_days_in_period,
    p_date_range,

    CASE
        WHEN p_freq = 1 THEN TO_CHAR(p_start_of_period, 'DD/MM/YYYY')
        WHEN p_freq = 2 THEN 'w' || TO_CHAR(p_start_of_period, 'IW IYYY')
        WHEN p_freq = 3 THEN TO_CHAR(p_start_of_period, 'MM YYYY')
        WHEN p_freq = 4 THEN 'Q' || TO_CHAR(p_start_of_period, 'Q YYYY')
        WHEN p_freq = 5 THEN TO_CHAR(p_start_of_period, 'YYYY')
    END                                                                    AS p_period_name,

    SUBSTR(EXTRACT(YEAR FROM p_start_of_period)::text, 1, 3) || '0s'       AS p_decade_name

    -- Status
    CASE
        WHEN p_end_of_period < CURRENT_DATE THEN 'Past'
        WHEN p_start_of_period > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END                                                                    AS p_status,

    -- Lag period number, frequency related
    p_lag

FROM ce_core.period;

COMMENT ON VIEW ce_core.v_period
    IS 'View - generated periods';
