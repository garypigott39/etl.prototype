/*
 ***********************************************************************************************************
 * @file
 * s_pipeline_lock.sql
 *
 * System table - generic pipeline "locks", enabling us to lock/unlock a pipeline for processing.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.s_pipeline_lock;

CREATE TABLE IF NOT EXISTS ce_warehouse.s_pipeline_lock
(
    name TEXT NOT NULL,
    locked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Locked timestamp

    PRIMARY KEY (name)
);

COMMENT ON TABLE ce_warehouse.s_pipeline_lock
    IS 'System table - generic pipeline "locks", enabling us to lock/unlock a pipeline for processing';
