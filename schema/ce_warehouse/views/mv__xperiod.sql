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
	src.ifreq             AS s_ifreq,
	tgt.ifreq             AS ifreq,
	tgt.pk_pdi            AS pdi
FROM ce_warehouse.mv__period src
    JOIN ce_warehouse.mv__period tgt
        ON tgt.date_range @> src.dt_mid_of_period
        AND tgt.ifreq > src.ifreq
GROUP BY
    1, 2, 3;

CREATE UNIQUE INDEX IF NOT EXISTS mv__xperiod__s_datapoint__idx
    ON ce_warehouse.mv__xperiod (s_ifreq, pdi);

CREATE INDEX IF NOT EXISTS mv__xperiod__t_datapoint__idx
    ON ce_warehouse.mv__xperiod (ifreq, pdi);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv__xperiod
    IS 'Materialized View - creates a source to target period table, for use in API calculations etc';
