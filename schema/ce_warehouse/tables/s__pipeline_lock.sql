/*
 ***********************************************************************************************************
 * @file
 * s__lock.sql
 *
 * System table - generic "locks", enabling us to lock/unlock a pipeline (or whatever) for processing.
  *
 * NOTE, we don't use the text validation functions in any of the "s_" system tables because they are
 * potentially used by the validation functions, so we need to have more basic validation rules in place
 * to avoid circular references.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.s__lock;

CREATE TABLE IF NOT EXISTS ce_warehouse.s__lock
(
    name TEXT NOT NULL
        CHECK (name ~ '^[A-Z][A-Z0-9.-]*[A-Z0-9]$'),  -- Valid pipeline name format
    ts_locked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Locked timestamp

    PRIMARY KEY (name)
);

COMMENT ON TABLE ce_warehouse.s__lock
    IS 'System table - generic "locks", enabling us to lock/unlock a pipeline (or whatever) for processing';
