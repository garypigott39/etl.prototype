/*
 ***********************************************************************************************************
 * @file
 * px_ut__xsnapshot.sql
 *
 * Utility procedure - update values (slice) snapshot.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__xsnapshot;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__xsnapshot(
    _pks INT,
    _src_ifreq SMALLINT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO ce_warehouse.x__snapshot (
        fk_pk_series,
        lk_pk_pdi,
        itype,
        src_ifreq,
        eop_src_pdi,
        eop_src_value,
        sum_value,
        num_periods
    )
        WITH _pdi_values AS (
            SELECT
                v.fk_pk_series	AS fk_pk_series,
                v.itype         AS itype,
                v.lk_pk_pdi		AS src_pdi,
                v.ifreq			AS src_ifreq,
                v.value			AS value,
                xp.tgt_pdi      AS tgt_pdi,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        v.fk_pk_series, v.itype, xp.tgt_pdi
                    ORDER BY
                        v.lk_pk_pdi DESC
                )				AS rn
            FROM ce_warehouse.x__value v
                JOIN ce_warehouse.mv__xperiod xp
                    ON xp.src_ifreq = v.ifreq
                    AND xp.src_pdi_range @> v.lk_pk_pdi
            WHERE v.fk_pk_series  =_pks
            AND v.ifreq = _src_ifreq
        )
        SELECT
            fk_pk_series    	AS fk_pk_series,
            MAX(tgt_pdi)    	AS lk_pk_pdi,
            itype               AS itype,
            src_ifreq       	AS src_ifreq,
            MAX(CASE WHEN rn = 1 THEN src_pdi END)
                                AS eop_pdi,
            MAX(CASE WHEN rn = 1 THEN value END)
                                AS eop_value,
            SUM(value)      	AS sum_value,
            COUNT(DISTINCT src_pdi)
                                AS num_periods
        FROM _pdi_values
        GROUP BY
            fk_pk_series, itype, src_ifreq, tgt_freq;

    ON CONFLICT (fk_pk_series, lk_pk_pdi, src_ifreq, itype)
        DO UPDATE SET
            eop_pdi = EXCLUDED.eop_pdi,
            eop_value = EXCLUDED.eop_value,
            sum_value = EXCLUDED.sum_value,
            num_periods = EXCLUDED.num_periods,
            ts_updated = NOW()
        -- Only update if values have changed (to avoid unnecessary updates)
        WHERE ce_warehouse.x__snapshot.eop_pdi IS DISTINCT FROM EXCLUDED.eop_pdi
        OR ce_warehouse.x__snapshot.eop_value IS DISTINCT FROM EXCLUDED.eop_value
        OR ce_warehouse.x__snapshot.sum_value IS DISTINCT FROM EXCLUDED.sum_value
        OR ce_warehouse.x__snapshot.num_periods IS DISTINCT FROM EXCLUDED.num_periods;

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__xsnapshot
    IS 'Utility procedure - update values (slice) snapshot';
