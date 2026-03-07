/*
 ***********************************************************************************************************
 * @file
 * mv__xperiod.sql
 *
 * Materialized View - creates a source to target period table, for use in API calculations etc.
 ***********************************************************************************************************
 */

DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv__xperiod;

CREATE MATERIALIZED VIEW ce_warehouse.mv__xperiod
AS
SELECT
	src.ifreq           AS src_ifreq,
	tgt.ifreq           AS tgt_ifreq,
	tgt.pk_pdi          AS tgt_pdi,
	INT4RANGE(MIN(src.pk_pdi), MAX(src.pk_pdi) + 1, '[)')
                        AS src_pdi_range
FROM ce_warehouse.mv__period src
    JOIN ce_warehouse.mv__period tgt
        ON tgt.date_range @> src.dt_mid_of_period
        AND tgt.ifreq > src.ifreq
GROUP BY
    1, 2, 3;

CREATE UNIQUE INDEX IF NOT EXISTS mv__xperiod__src_datapoint__idx
    ON ce_warehouse.mv__xperiod (src_ifreq, tgt_pdi);

CREATE INDEX IF NOT EXISTS mv__xperiod__tgt_datapoint__idx
    ON ce_warehouse.mv__xperiod (tgt_ifreq, tgt_pdi);

-- GIST "Generalized Search Tree" index -> performant for range queries
CREATE INDEX IF NOT EXISTS mv__xperiod__src_pdirange__idx
    ON ce_warehouse.mv__xperiod USING GIST (src_ifreq, src_pdi_range);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv__xperiod
    IS 'Materialized View - creates a source to target period table, for use in API calculations etc';
