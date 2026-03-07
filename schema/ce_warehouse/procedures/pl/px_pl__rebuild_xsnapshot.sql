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
        src_ifreq,
        fk_pk_series,
        lk_pk_pdi,
        itype,
        last_pdi,
        last_value,
        sum_value,
        num_periods
    )
        SELECT
            src_ifreq,
            fk_pk_series,
            lk_pk_pdi,
            itype,
            last_pdi,
            last_value,
            sum_value,
            num_periods
        FROM ce_warehouse.fx_tb__xvalue_to_snapshot();

    CALL ce_warehouse.px_ut__info('Pipeline - Rebuild snapshot ends', TRUE);

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__rebuild_xsnapshot
    IS 'Pipeline procedure - batch update/rebuild values (slice) snapshot';
