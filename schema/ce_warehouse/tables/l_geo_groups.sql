/*
 ***********************************************************************************************************
 * @file
 * l_geo_group.sql
 *
 * Lookup table - GEO group lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_geo_group;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_geo_group
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9_-]*$'),
    name TEXT NOT NULL
        CHECK (name ~ '^[A-Z][A-Za-z0-9 &_,-]*$'),

    PRIMARY KEY (code),
    UNIQUE (name)
);

COMMENT ON TABLE ce_warehouse.l_geo_group
    IS 'Lookup table - GEO group lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_geo_group (code, name)
VALUES
    ('Africa_Middle_East_CE','Africa Middle East CE'),
    ('Africa_UN','Africa UN'),
    ('APAC', 'APAC'),
    ('Asia_ex_Japan_CE','Asia ex Japan CE'),
    ('Asia_ex_Japan_China_CE','Asia ex Japan China CE'),
    ('Asia_ex_Japan_China_India_CE','Asia ex Japan China India CE'),
    ('Asia_Pacific_CE','Asia Pacific CE'),
    ('Asia_UN','Asia UN'),
    ('DM','DM'),
    ('EM','EM'),
    ('EM_Asia_ex_China_CE','EM Asia ex China CE'),
    ('EM_Asia_ex_China_India_CE','EM Asia ex China India CE'),
    ('Emerging_Asia_CE','Emerging Asia CE'),
    ('Emerging_Europe_CE','Emerging Europe CE'),
    ('European_Union','European Union'),
    ('Europe_CE','Europe CE'),
    ('Europe_UN','Europe UN'),
    ('Euro-zone','Euro-zone'),
    ('G10','G10'),
    ('G20','G20'),
    ('G4','G4'),
    ('G7','G7'),
    ('Latin_America_Caribbean_UN','Latin America Caribbean UN'),
    ('Latin_America_CE','Latin America CE'),
    ('Major_DM','Major DM'),
    ('Major_EM','Major EM'),
    ('Major_Global','Major Global'),
    ('Middle_East_North_Africa_CE','Middle East North Africa CE'),
    ('North_America_UN','North America UN'),
    ('Oceania_UN','Oceania UN'),
    ('OECD','OECD'),
    ('Sub_Saharan_Africa_CE','Sub Saharan Africa CE'),
    ('US', 'US');
