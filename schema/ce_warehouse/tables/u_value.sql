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

-- DROP TABLE IF EXISTS ce_warehouse.u_value;

CREATE TABLE IF NOT EXISTS ce_warehouse.u_value
(
    idx INT GENERATED ALWAYS AS IDENTITY,

    uv_gcode TEXT,
    uv_icode TEXT,
    uv_period TEXT,
    uv_cfreq TEXT,    -- CHAR version of frequency
    uv_ctype TEXT,    -- CHAR version of type
    uv_source TEXT,  -- CHAR version of source
    uv_value TEXT,
    uv_tooltip TEXT,
    update_type TEXT,  -- NEW, UPDATE, DELETE or UNCHANGED
    -- Calculated
    pk_series INT,
    pdi INT,
    ifreq SMALLINT,
    itype SMALLINT,
    isource SMALLINT,
    -- End

    is_api BOOL NOT NULL,  -- flag to indicate if the value is from an API (set via manual loader)

    file_name TEXT,
    error TEXT,  -- system generated

    PRIMARY KEY (idx)
);

-- Add index on gcode/icode/period for duplicates checking speed
CREATE INDEX IF NOT EXISTS u_value__datapoint__idx
    ON ce_warehouse.u_value (uv_gcode, uv_icode, uv_period);

COMMENT ON TABLE ce_warehouse.u_value
    IS 'Userdata table - datapoint values from API (or CSV)';