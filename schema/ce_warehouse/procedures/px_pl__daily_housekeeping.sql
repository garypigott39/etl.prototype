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

    ----------------------------------------------------------------
    -- Acquire lock (persists via COMMIT inside lock proc)
    ----------------------------------------------------------------
    CALL ce_warehouse.px_ut__lock_pipeline('ETL', 'lock');

    BEGIN
        ----------------------------------------------------------------
        -- Main housekeeping block (fully rollbackable)
        ----------------------------------------------------------------

        -- Fix sequences
        CALL ce_warehouse.px_ut__info('Running sequence fix', TRUE);
        CALL ce_warehouse.px_ut__fix_seq();

        -- Generate dates & periods
        CALL ce_warehouse.px_ut__info('Generating dates & periods', TRUE);
        CALL ce_warehouse.px_ut__generate_dates();

        -- Sync Django users
        CALL ce_warehouse.px_ut__info('Syncing users', TRUE);
        CALL ce_warehouse.px_ut__sync_users();

    EXCEPTION WHEN OTHERS THEN
        ----------------------------------------------------------------
        -- If anything fails:
        --  • housekeeping changes rollback automatically
        --  • rethrow error
        -- Pipeline remains locked to prevent further runs until issue is resolved and pipeline manually unlocked
        ----------------------------------------------------------------

        CALL ce_warehouse.px_ut__info(
            'Pipeline - Daily Housekeeping failed: ' || SQLERRM,
            TRUE
        );

        RAISE;
    END;

    CALL ce_warehouse.px_ut__info('Pipeline - Daily Housekeeping ends OK', TRUE);

    ----------------------------------------------------------------
    -- Success path: unlock pipeline
    ----------------------------------------------------------------
    CALL ce_warehouse.px_ut__lock_pipeline('ETL', 'unlock');

END;
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__daily_housekeeping
    IS 'Pipeline procedure - simulate daily "housekeeping" tasks';
