/*
 ***********************************************************************************************************
 * @file
 * u_value_onhold.sql
 *
 * Userdata table - datapoint values with errors; subject to "cleanup" by housekeeping apps after N days.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.u_value__errors;

CREATE TABLE IF NOT EXISTS ce_warehouse.u_value__errors
(
    idx INT GENERATED ALWAYS AS IDENTITY,

    gcode TEXT,
    icode TEXT,
    period TEXT,
    cfreq TEXT,    -- CHAR version of frequency
    ctype TEXT,    -- CHAR version of type
    csource TEXT,  -- CHAR version of source
    cvalue TEXT,   -- CHAR version of value
    tooltip TEXT,
    update_type TEXT,  -- NEW, UPDATE, DELETE or UNCHANGED

    -- Track who uploaded the file (annotation only)
    uploaded_by TEXT NOT NULL,

    is_api BOOL NOT NULL,  -- flag to indicate if the value is from an API (set via manual loader)

    file_name TEXT,
    error TEXT,

    ts_created TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (idx)
);

COMMENT ON TABLE ce_warehouse.u_value__errors
    IS 'Userdata table - datapoint values with errors; subject to "cleanup" by housekeeping apps after N days';