/*
 ***********************************************************************************************************
 * @file
 * l_politcal_alignment.sql
 *
 * Lookup table - political alignment lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_etl.l_political_alignment;

CREATE TABLE IF NOT EXISTS ce_etl.l_political_alignment
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Za-z0-9 ]*$'),
    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_etl.l_political_alignment
    IS 'Lookup table - political alignment lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_etl.l_political_alignment
VALUES
    ('Strong US'),
    ('Leans US'),
    ('Unaligned'),
    ('Leans China'),
    ('Strong China');