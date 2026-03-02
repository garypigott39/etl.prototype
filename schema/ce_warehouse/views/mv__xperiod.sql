/*
 ***********************************************************************************************************
 * @file
 * mv__xperiod.sql
 *
 * Materialized View - creates a source to target period table, for use in API calculations etc.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv__xperiod;

CREATE MATERIALIZED VIEW ce_warehouse.mv__xperiod
AS
SELECT
    src.pk_pdi            AS src_pdi,
    src.ifreq             AS src_ifreq,
    tgt.pk_pdi            AS tgt_pdi,
    tgt.ifreq             AS tgt_ifreq,
    tgt.period            AS tgt_period,
    tgt.dt_end_of_period  AS tgt_dt_end_of_period
FROM ce_warehouse.mv__period src
    JOIN ce_warehouse.mv__period tgt
        ON tgt.date_range @> src.dt_mid_of_period
        AND tgt.ifreq > src.ifreq;

CREATE INDEX IF NOT EXISTS mv__xperiod__src_datapoint__idx
    ON ce_warehouse.mv__xperiod (src_pdi, src_ifreq);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv__xperiod
    IS 'Materialized View - creates a source to target period table, for use in API calculations etc';
