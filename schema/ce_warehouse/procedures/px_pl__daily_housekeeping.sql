/*
 ***********************************************************************************************************
 * @file
 * px_pl__daily_housekeeping.sql
 *
 * Pipeline procedure - simulate daily "housekeeping" tasks.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_pl__daily_housekeeping;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_pl__daily_housekeeping(
)
    LANGUAGE plpgsql
AS
$$
BEGIN

    CALL ce_warehouse.px_ut__info('Pipeline - Daily Housekeeping starts', TRUE);

    CALL ce_warehouse.px_ut__lock_or_unlock('ETL', 'lock');

    -- Fix sequences
    CALL ce_warehouse.px_ut__info('Running sequence fix', TRUE);
    CALL ce_warehouse.px_ut__fix_seq();

    -- Generate dates & periods
    CALL ce_warehouse.px_ut__info('Generating dates & periods', TRUE);
    CALL ce_warehouse.px_ut__generate_dates();

    -- Sync Django users
    CALL ce_warehouse.px_ut__info('Syncing users', TRUE);
    CALL ce_warehouse.px_ut__sync_users();

    -- Unlock pipeline
    CALL ce_warehouse.px_ut__lock_or_unlock('ETL', 'unlock');

    CALL ce_warehouse.px_ut__info('Pipeline - Daily Housekeeping ends OK', TRUE);

END;
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__daily_housekeeping
    IS 'Pipeline procedure - simulate daily "housekeeping" tasks';
