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
    _src_ifreq INT
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
        last_pdi,
        last_value,
        sum_value,
        num_periods
    )
        SELECT
            fk_pk_series,
            lk_pk_pdi,
            src_ifreq,
            itype,
            last_pdi,
            last_value,
            sum_value,
            num_periods
        FROM ce_warehouse.fx_tb__xvalue_to_snapshot(_pks, _src_ifreq)

        ON CONFLICT (fk_pk_series, lk_pk_pdi, src_ifreq, itype)
            DO UPDATE SET
                last_pdi = EXCLUDED.last_pdi,
                last_value = EXCLUDED.last_value,
                sum_value = EXCLUDED.sum_value,
                num_periods = EXCLUDED.num_periods,
                ts_updated = NOW()

        -- Only update if values have changed (to avoid unnecessary updates)
        WHERE ce_warehouse.x__snapshot.last_pdi IS DISTINCT FROM EXCLUDED.last_pdi
        OR ce_warehouse.x__snapshot.last_value IS DISTINCT FROM EXCLUDED.last_value
        OR ce_warehouse.x__snapshot.sum_value IS DISTINCT FROM EXCLUDED.sum_value
        OR ce_warehouse.x__snapshot.num_periods IS DISTINCT FROM EXCLUDED.num_periods;

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__xsnapshot
    IS 'Utility procedure - update values (slice) snapshot';
