/*
 ***********************************************************************************************************
 * @file
 * l_type.sql
 *
 * Lookup table - account type lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_type;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_type
(
    pk_t SMALLINT NOT NULL
        CHECK (pk_t IN (1, 2)),

    code TEXT NOT NULL
        CHECK (code IN ('AC','F')),  -- restrict to valid codes
    name TEXT NOT NULL,

    PRIMARY KEY (pk_t),
    UNIQUE (code)
);

COMMENT ON TABLE ce_warehouse.l_type
    IS 'Lookup table - account type lookup';

/**
 * Pre-populate with known values. THIS WILL NEVER CHANGE!!!
 */
INSERT INTO ce_warehouse.l_type
VALUES
    (1, 'AC', 'Actual'),
    (2, 'F', 'Forecast');
