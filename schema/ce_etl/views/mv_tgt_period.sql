/*
 ***********************************************************************************************************
 * @file
 * mv_tgt_period.sql
 *
 * Materialized View - creates a source to target period table, for use in API calculations etc.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_etl.mv_tgt_period;

CREATE MATERIALIZED VIEW ce_etl.mv_tgt_period
AS
    SELECT
        src.pk_p             AS src_pdi,
        src.p_freq           AS src_freq,
        tgt.pk_p             AS tgt_pdi,
        tgt.p_freq           AS tgt_freq,
        tgt.p_period         AS tgt_period,
        tgt.p_end_of_period  AS tgt_end_of_period
      FROM ce_etl.mv_period src
      JOIN ce_etl.mv_.period tgt
          ON tgt.p_date_range @> src.p_mid_of_period
         AND tgt.p_freq > src.p_freq;

CREATE INDEX IF NOT EXISTS mv_tgt_period__src_index
    ON ce_etl.mv_period (src_pdi, src_freq);

COMMENT ON MATERIALIZED VIEW ce_etl.mv_tgt_period
    IS 'Materialized View - creates a source to target period table, for use in API calculations etc';
