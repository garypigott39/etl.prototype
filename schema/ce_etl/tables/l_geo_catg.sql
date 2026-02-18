/*
 ***********************************************************************************************************
 * @file
 * l_geo_catg.sql
 *
 * Lookup table - geo category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_etl.l_geo_catg;

CREATE TABLE IF NOT EXISTS ce_etl.l_geo_catg
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9 ]*$'),
    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_etl.l_geo_catg
    IS 'Lookup table - geo category lookup';

/**
 * Pre-populate with known values. Update as required.
 */

 INSERT INTO ce_etl.l_geo_catg
 VALUES
    ('Country'),
    ('Region'),
    ('Subnational'),
    ('Unknown');
