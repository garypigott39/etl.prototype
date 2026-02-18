/*
 ***********************************************************************************************************
 * @file
 * l_com_type.sql
 *
 * Lookup table - commodity type lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_com_type;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_com_type
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][a-z0-9 ]*$'),
    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.l_com_type
    IS 'Lookup table - commodity type lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_com_type
VALUES
    ('Agriculturals'),
    ('Commodity index'),
    ('Energy'),
    ('Industrial metals'),
    ('Precious metals');