/*
 ***********************************************************************************************************
 * @file
 * mv_xvalue.sql
 *
 * Materialized View - used in calc API processing.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv_xvalue;

CREATE MATERIALIZED VIEW ce_warehouse.mv_xvalue
AS
SELECT
    fk_pk_series,
    ifreq                AS src_ifreq,
    MAX(pdi)             AS src_pdi,
    tgt_ifreq            AS tgt_ifreq,
    tgt_pdi              AS tgt_pdi,
    MAX(tgt_period)      AS tgt_period,
    SUM(value)           AS sum_value,
    MAX(CASE WHEN rn = 1 THEN value END)
                         AS last_value,
    COUNT(DISTINCT pdi)  AS ct_periods
FROM (
    SELECT
        x.fk_pk_series,
        x.ifreq,
        x.pdi,
        p.tgt_ifreq,
        p.tgt_period,
        p.tgt_pdi,
        x.value,
        ROW_NUMBER() OVER (
          PARTITION BY
              x.fk_pk_series, x.ifreq, p.tgt_ifreq, p.tgt_pdi
          ORDER BY x.pdi DESC
        ) AS rn
    FROM ce_warehouse.x_value x
    JOIN ce_warehouse.mv_xperiod p
        ON x.pdi = p.src_pdi
        AND x.ifreq = p.src_ifreq
    WHERE x.itype = 1  -- 'AC' only, belt & braces
) s
GROUP BY
    fk_pk_series, ifreq, tgt_ifreq, tgt_pdi;

CREATE INDEX IF NOT EXISTS mv_xvalue__fk_pk_series__idx
    ON ce_warehouse.mv_xvalue (fk_pk_series);

-- For performance of "calc" JOINs
CREATE INDEX IF NOT EXISTS mv_xvalue__ud_calc__idx
    ON ce_warehouse.mv_xvalue (fk_pk_series, src_pdi, src_freq);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv_xvalue
    IS 'Materialized View - used in calc API processing';
