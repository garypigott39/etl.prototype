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
    name TEXT NOT NULL
        CHECK (ce_warehouse.fx_val_is_name(name) IS NULL),

    PRIMARY KEY (name)
);

COMMENT ON TABLE ce_warehouse.l_com_type
    IS 'Lookup table - commodity type lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_com_type (code)
VALUES
    ('Agriculturals'),
    ('Commodity index'),
    ('Energy'),
    ('Industrial metals'),
    ('Precious metals');