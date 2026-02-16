/*
 ***********************************************************************************************************
 * @file
 * s_pipeline_locks.sql
 *
 * System table - generic pipeline "locks", enabling us to lock/unlock a pipeline for processing.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_etl.s_pipeline_locks;

CREATE TABLE IF NOT EXISTS ce_etl.s_pipeline_locks
(
    name TEXT NOT NULL,
    locked_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Locked timestamp
    PRIMARY KEY (name)
);

COMMENT ON TABLE ce_etl.s_pipeline_locks
    IS 'System table - generic pipeline "locks", enabling us to lock/unlock a pipeline for processing';
