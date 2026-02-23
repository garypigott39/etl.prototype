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
    pk_t SMALLINT NOT NULL GENERATED ALWAYS AS (
        CASE code
            WHEN 'AC' THEN 1
            WHEN 'F' THEN 2
        END
    ) STORED,

    code TEXT NOT NULL
        CHECK (code IN ('AC','F')),  -- restrict to valid codes

    name TEXT NOT NULL GENERATED ALWAYS AS (,
        CASE code
            WHEN 'AC' THEN 'Actual'
            WHEN 'F' THEN 'Forecast'
        END
    ) STORED,

    PRIMARY KEY (pk_t),
    UNIQUE (code)
);

COMMENT ON TABLE ce_warehouse.l_type
    IS 'Lookup table - account type lookup';

/**
 * Pre-populate with known values. THIS WILL NEVER CHANGE!!!
 */
INSERT INTO ce_warehouse.l_type (code)
VALUES
    ('AC'),
    ('F');
