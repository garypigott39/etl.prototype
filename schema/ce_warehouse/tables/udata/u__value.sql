/*
 ***********************************************************************************************************
 * @file
 * u_value.sql
 *
 * Userdata table - datapoint values from API (or CSV).
 *
 * Note, we expect the APIs (as we write them) to provide valid data. But the processing pipeline logic
 * will handle any issues like invalid codes, etc.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.u__value;

CREATE TABLE IF NOT EXISTS ce_warehouse.u__value
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

    -- Calculated
    pk_series INT,
    pdi INT,
    ifreq SMALLINT,
    itype SMALLINT,
    isource INT,
    -- End

    file_name TEXT,
    error TEXT,  -- system generated

    PRIMARY KEY (idx)
);

-- Add index on gcode/icode/period for duplicates checking speed
CREATE INDEX IF NOT EXISTS u_value__datapoint__idx
    ON ce_warehouse.u__value (gcode, icode, period);

-- It's recommended to have INDICES on foreign keys for performance!! (particularly important for large tables)
CREATE INDEX IF NOT EXISTS u__value__uploaded_by__idx
    ON ce_warehouse.u__value (uploaded_by);

COMMENT ON TABLE ce_warehouse.u__value
    IS 'Userdata table - datapoint values from API (or CSV)';