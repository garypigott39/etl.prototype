/*
 ***********************************************************************************************************
 * @file
 * px_pl__rebuild_xsnapshot.sql
 *
 * Pipeline procedure - batch update/rebuild values (slice) snapshot.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_pl__rebuild_xsnapshot;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_pl__rebuild_xsnapshot(
)
    LANGUAGE plpgsql
AS
$$
BEGIN

    CALL ce_warehouse.px_ut__info('Pipeline - Rebuild snapshot starts', TRUE);

    TRUNCATE TABLE ce_warehouse.x__snapshot RESTART IDENTITY;

    INSERT INTO ce_warehouse.x__snapshot (
        fk_pk_series,
        lk_pk_pdi,
        itype,
        tgt_ifreq,
        src_ifreq,
        src_last_pdi,
        src_last_value,
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
        )
        SELECT
            fk_pk_series    	AS fk_pk_series,
            MAX(tgt_pdi)    	AS lk_pk_pdi,
            itype               AS itype,
            src_ifreq       	AS src_ifreq,
            MAX(CASE WHEN rn = 1 THEN src_pdi END)
                                AS src_last_pdi,
            MAX(CASE WHEN rn = 1 THEN value END)
                                AS src_last_value,
            SUM(value)      	AS sum_value,
            COUNT(DISTINCT src_pdi)
                                AS num_periods
        FROM _pdi_values
        GROUP BY
            fk_pk_series, itype, src_ifreq, tgt_freq;

    CALL ce_warehouse.px_ut__info('Pipeline - Rebuild snapshot ends', TRUE);

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__rebuild_xsnapshot
    IS 'Pipeline procedure - batch update/rebuild values (slice) snapshot';
