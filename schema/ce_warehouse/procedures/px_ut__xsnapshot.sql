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
    _src_ifreq SMALLINT,
    _itype SMALLINT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO ce_warehouse.x__snapshot (
        fk_pk_series,
        lk_pk_pdi,
        src_ifreq,
        itype,
        eop_pdi,
        eop_value,
        sum_value,
        num_periods
    )
        WITH _base AS (
            SELECT
                v.fk_pk_series,
                v.lk_pk_pdi,
                v.value,
                v.ifreq,
                v.itype
            FROM ce_warehouse.x__value v
            WHERE v.fk_pk_series = _pks
            AND v.ifreq = _src_ifreq
            AND v.itype = _itype
        ),
        _mapped AS (
            SELECT
                b.fk_pk_series  AS pks,
                p.pdi           AS tgt_pdi,
                b.lk_pk_pdi     AS src_pdi,
                b.value         AS value,
                b.ifreq         AS ifreq,
                b.itype         AS itype
            FROM _base b
                JOIN ce_warehouse.mv__xperiod p
                    ON p.s_ifreq = b.ifreq
        ),
        _aggregated AS (
            SELECT
                pks             AS pks,
                tgt_pdi         AS tgt_pdi,
                ifreq           AS src_ifreq,
                itype           AS itype,
                MAX(src_pdi)    AS eop_pdi,
                SUM(value)      AS sum_value,
                COUNT(*)        AS num_periods
            FROM _mapped
            GROUP BY
                pks, tgt_pdi, ifreq, itype
        )
        SELECT
            a.pks               AS fk_pk_series,
            a.tgt_pdi           AS lk_pk_pdi,
            a.src_ifreq         AS src_ifreq,
            a.itype             AS itype,
            a.eop_pdi           AS eop_pdi,
            v.value             AS eop_value,
            a.sum_value         AS sum_value,
            a.num_periods       AS num_periods
        FROM _aggregated a
            JOIN ce_warehouse.x__value v
                ON v.fk_pk_series = a.pks
                AND v.lk_pk_pdi = a.eop_pdi
                AND v.itype = a.itype
        ON CONFLICT (fk_pk_series, lk_pk_pdi, src_ifreq, itype)
            DO UPDATE SET
                eop_pdi = EXCLUDED.eop_pdi,
                eop_value = EXCLUDED.eop_value,
                sum_value = EXCLUDED.sum_value,
                num_periods = EXCLUDED.num_periods,
                ts_updated = NOW()
            WHERE ce_warehouse.x__snapshot.eop_pdi IS DISTINCT FROM EXCLUDED.eop_pdi
            OR ce_warehouse.x__snapshot.eop_value IS DISTINCT FROM EXCLUDED.eop_value
            OR ce_warehouse.x__snapshot.sum_value IS DISTINCT FROM EXCLUDED.sum_value
            OR ce_warehouse.x__snapshot.num_periods IS DISTINCT FROM EXCLUDED.num_periods;

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__xsnapshot
    IS 'Utility procedure - update values (slice) snapshot';
