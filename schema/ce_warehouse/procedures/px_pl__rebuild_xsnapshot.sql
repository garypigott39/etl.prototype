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
DECLARE
    _rec RECORD;

BEGIN

    CALL ce_warehouse.px_ut__info('Pipeline - Rebuild snapshot starts', TRUE);

    FOR _rec IN
        SELECT DISTINCT fk_pk_series, ifreq, itype
        FROM ce_warehouse.x__value
    LOOP
        CALL ce_warehouse.px_ut__xsnapshot(
            _rec.fk_pk_series,
            _rec.ifreq,
            _rec.itype
        );
    END LOOP;

    /***************************************************************************************************
     * Cleanup orphaned snapshots (if any) - these can occur if the trigger was disabled
     * for a while and then re-enabled, or if there were bulk deletes in x_value without corresponding
     * snapshot cleanup.
     ***************************************************************************************************/
    DELETE FROM ce_warehouse.x__snapshot xs
    WHERE NOT EXISTS(
        SELECT 1
        FROM ce_warehouse.x__value v
        WHERE v.fk_pk_series = xs.fk_pk_series
        AND v.ifreq = xs.src_ifreq
        AND v.itype = xs.itype
    );

    CALL ce_warehouse.px_ut__info('Pipeline - Rebuild snapshot ends', TRUE);

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__rebuild_xsnapshot
    IS 'Pipeline procedure - batch update/rebuild values (slice) snapshot';
