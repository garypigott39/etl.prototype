/*
 ***********************************************************************************************************
 * @file
 * px_ut_lock_pipeline.sql
 *
 * Utility procedure - lock/unlock named pipeline.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_etl.px_ut_lock_pipeline;

CREATE OR REPLACE PROCEDURE ce_etl.px_ut_lock_pipeline(
    _name TEXT DEFAULT NULL,
    _type TEXT DEFAULT 'lock',  -- lock/unlock
    _interval INTERVAL DEFAULT '1 hour'  -- Interval for checking if the pipeline is locked
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    _ts TIMESTAMP := NOW() AT TIME ZONE 'UTC' - _interval;
BEGIN
    _name := UPPER(TRIM(_name));

    IF _name IS NULL THEN
        RAISE EXCEPTION 'Pipeline name must be provided';
    ELIF _type = 'lock' THEN
        IF (SELECT COUNT(*) FROM ce_etl.s_pipeline_locks WHERE name = _name AND locked_utc > _ts) > 0 THEN
            RAISE EXCEPTION 'Pipeline "%" is already locked', _name;
        ELSE
            DELETE FROM ce_etl.s_pipeline_locks WHERE name = _name;
            INSERT INTO ce_etl.s_pipeline_locks(name) VALUES (_name);
            RAISE INFO 'Pipeline "%" locked', _name;
        END IF;
    ELIF _type = 'unlock' THEN
        -- Unlock the pipeline
        DELETE FROM ce_etl.s_pipeline_locks WHERE name = _name;
        RAISE INFO 'Pipeline "%" unlocked', _name;
    ELSE
        RAISE EXCEPTION 'Invalid type "%" - must be lock or unlock', _type;
    END IF;
END
$$;

COMMENT ON PROCEDURE ce_etl.px_ut_lock_pipeline
    IS 'Utility procedure - lock/unlock named pipeline';
