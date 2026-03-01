/*
 ***********************************************************************************************************
 * @file
 * mv_period.sql
 *
 * Materialized View - generated periods.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv_period;

CREATE MATERIALIZED VIEW IF NOT EXISTS ce_warehouse.mv_period
AS
SELECT
    p.pk_pdi                AS pk_pdi,
    p.period                AS period,
    p.dt_start_of_period    AS dt_start_of_period,
    (p.dt_start_of_period + (p.dt_end_of_period - p.dt_start_of_period) / 2)::DATE
                            AS dt_mid_of_period,
    p.dt_end_of_period      AS dt_end_of_period,
    (p.dt_end_of_period - p.dt_start_of_period) + 1
                            AS days_in_period,
    p.ifreq                 AS ifreq,
    f.code                  AS freq_code,
    p.date_range            AS date_range,
    CASE p.ifreq
        WHEN 1 THEN TO_CHAR(dt_start_of_period, 'DD/MM/YYYY')
        WHEN 2 THEN 'w' || TO_CHAR(dt_start_of_period, 'IW IYYY')
        WHEN 3 THEN TO_CHAR(dt_start_of_period, 'MM YYYY')
        WHEN 4 THEN 'Q' || TO_CHAR(dt_start_of_period, 'Q YYYY')
        ELSE TO_CHAR(dt_start_of_period, 'YYYY')
    END                     AS period_name,
    SUBSTR(EXTRACT(YEAR FROM p.dt_start_of_period)::TEXT, 1, 3) || '0s'
                            AS decade_name,
    CASE
        WHEN p.dt_end_of_period < CURRENT_DATE THEN 'Past'
        WHEN p.dt_start_of_period > CURRENT_DATE THEN 'Future'
        ELSE 'Current'
    END                     AS status,
    p.lag                   AS lag

FROM ce_warehouse.l__period p
    LEFT JOIN ce_warehouse.l__freq f
        ON p.ifreq = f.pk_freq;

CREATE UNIQUE INDEX mv_period__pk__idx
    ON ce_warehouse.mv_period(pk_pdi);

CREATE UNIQUE INDEX mv_period__period__idx
    ON ce_warehouse.mv_period(period);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS mv_period__date_range__idx
    ON ce_warehouse.mv_period USING GIST (date_range);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv_period
    IS 'Materialized View - generated periods';
