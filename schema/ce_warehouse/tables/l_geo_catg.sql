/*
 ***********************************************************************************************************
 * @file
 * l_geo_catg.sql
 *
 * Lookup table - GEO category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_geo_catg;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_geo_catg
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9 &]*$'),

    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.l_geo_catg
    IS 'Lookup table - GEO category lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_geo_catg (code)
VALUES
    ('Country'),
    ('Region'),
    ('Subnational'),
    ('Unknown');
