/*
 ***********************************************************************************************************
 * @file
 * l_ind_narrow_catg.sql
 *
 * Lookup table - IND narrow category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_ind_narrow_catg;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_ind_narrow_catg
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9 &]*$'),

    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.l_ind_narrow_catg
    IS 'Lookup table - IND narrow category lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_ind_narrow_catg (code)
VALUES
    ('AI Index'),
    ('Asset Return'),
    ('Commodity price'),
    ('Commodity proxy'),
    ('Commodity risk premium'),
    ('Consumer'),
    ('Demographics'),
    ('Emissions'),
    ('EPC Shares'),
    ('External'),
    ('Financial Conditions Indices'),
    ('Financial Markets'),
    ('Financial Risk Monitors'),
    ('Fiscal'),
    ('FX'),
    ('GDP & Activity'),
    ('GDP component'),
    ('GDP Proxy'),
    ('Headline GDP'),
    ('Housing'),
    ('Income'),
    ('Industry'),
    ('Inflation'),
    ('Interest rate'),
    ('Interest rates'),
    ('Labour'),
    ('Leading indicator'),
    ('Lending'),
    ('Monetary policy'),
    ('Money & credit'),
    ('Mortgage risk'),
    ('Nowcast'),
    ('Population'),
    ('Productivity'),
    ('Property capital value growth'),
    ('Property income return'),
    ('Property rental growth'),
    ('Property rental value growth'),
    ('Property total return'),
    ('Property transactions'),
    ('Property vacancy rate'),
    ('Property valuation & affordability'),
    ('Property yield'),
    ('Survey'),
    ('Trade'),
    ('Transport');
