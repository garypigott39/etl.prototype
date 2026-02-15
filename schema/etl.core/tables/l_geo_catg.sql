/*
 ***********************************************************************************************************
 * @file
 * l_geo_catg.sql
 *
 * Lookup table - geo category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS core.l_geo_catg;

CREATE TABLE IF NOT EXISTS core.l_geo_catg
(
    code TEXT NOT NULL,
    PRIMARY KEY (code),
);

COMMENT ON TABLE core.l_geo_catg
    IS 'Lookup table - geo category lookup';

/**
 * Pre-populate with known values. Update as required.
 */

 INSERT INTO ce_data.s_geo_catg
 VALUES
    ('Country'),
    ('Region'),
    ('Subnational'),
    ('Unknown');
