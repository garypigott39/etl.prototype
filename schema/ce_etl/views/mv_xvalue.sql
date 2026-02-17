/*
 ***********************************************************************************************************
 * @file
 * mv_xvalue.sql
 *
 * Materialized View - used in calc API processing.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_etl.mv_xvalue;

CREATE MATERIALIZED VIEW ce_etl.mv_xvalue
AS
SELECT
    fk_pk_s,
    freq                 AS src_freq,
    MAX(pdi)             AS src_pdi,
    tgt_freq             AS tgt_freq,
    tgt_pdi              AS tgt_pdi,
    MAX(tgt_period)      AS tgt_period,
    SUM(value)           AS sum_value,
    MAX(CASE WHEN rn = 1 THEN value END)
                         AS last_value,
    COUNT(DISTINCT pdi)  AS ct_periods
FROM (
    SELECT
        x.fk_pk_s,
        x.freq,
        x.pdi,
        p.tgt_freq,
        p.tgt_period,
        p.tgt_pdi,
        x.value,
        ROW_NUMBER() OVER (
          PARTITION BY
              x.fk_pk_s, x.freq, p.tgt_freq, p.tgt_pdi
          ORDER BY x.pdi DESC
        ) AS rn
    FROM ce_etl.x_value x
    JOIN ce_etl.mv_xperiod p
       ON x.pdi = p.src_pdi AND x.freq = p.src_freq
    WHERE x.type = 1  -- 'AC' only, belt & braces
) s
GROUP BY
    fk_pk_s, freq, tgt_freq, tgt_pdi;

CREATE INDEX IF NOT EXISTS mv_xvalue__fk_pk_s__idx
    ON ce_etl.mv_xvalue (fk_pk_s);

-- For performance of "calc" JOINs
CREATE INDEX IF NOT EXISTS mv_xvalue__ud_calc__idx
    ON ce_etl.mv_xvalue (fk_pk_s, src_pdi, src_freq);

COMMENT ON MATERIALIZED VIEW ce_etl.mv_xvalue
    IS 'Materialized View - used in calc API processing';
