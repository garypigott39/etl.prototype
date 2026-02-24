/*
 ***********************************************************************************************************
 * @file
 * l_geo_category.sql
 *
 * Lookup table - GEO category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_geo_category;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_geo_category
(
    name TEXT NOT NULL
        CHECK (ce_warehouse.fx_val_is_name(name) IS NULL),

    PRIMARY KEY (name)
);

COMMENT ON TABLE ce_warehouse.l_geo_category
    IS 'Lookup table - GEO category lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_geo_category (name)
VALUES
    ('Country'),
    ('Region'),
    ('Subnational'),
    ('Unknown');
