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
    CALL ce_warehouse.px_ut__info('Pipeline - Daily Housekeeping starting', TRUE);

    -- Lock pipeline to prevent concurrent runs
    CALL ce_warehouse.px_ut__lock_pipeline('ETL', 'lock');

    -- Fix any SEQUENCEs that may be out of sync (e.g. after manual data loads)
    CALL ce_warehouse.px_ut__info('Running sequence fix', TRUE);
    CALL ce_warehouse.px_ut__fix_seq();

    -- Generate any missing dates & periods
    CALL ce_warehouse.px_ut__info('Generating dates & periods', TRUE);
    CALL ce_warehouse.px_ut__generate_dates();

    -- Any other housekeeping tasks could go her, @TBA

    -- Unlock pipeline
    CALL ce_warehouse.px_ut__lock_pipeline('ETL', 'unlock');

    CALL ce_warehouse.px_ut__info('Pipeline - Daily Housekeeping ends OK', TRUE);
END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_pl__daily_housekeeping
    IS 'Pipeline procedure - simulate daily "housekeeping" tasks';
