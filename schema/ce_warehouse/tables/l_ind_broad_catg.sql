/*
 ***********************************************************************************************************
 * @file
 * l_ind_broad_catg.sql
 *
 * Lookup table - IND broad category lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_ind_broad_catg;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_ind_broad_catg
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9 &]*$'),

    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.l_ind_broad_catg
    IS 'Lookup table - IND broad category lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_warehouse.l_ind_broad_catg (code)
VALUES
    ('Climate'),
    ('Commodities'),
    ('Macro'),
    ('Prroperty');