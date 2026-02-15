/*
 ***********************************************************************************************************
 * @file
 * l_data_transFORMATion.sql
 *
 * Lookup table - data transFORMATion lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_etl.l_data_transFORMATion;

CREATE TABLE IF NOT EXISTS ce_etl.l_data_transFORMATion
(
    code TEXT NOT NULL,
    PRIMARY KEY (code),
);

COMMENT ON TABLE ce_etl.l_data_transFORMATion
    IS 'Lookup table - data transFORMATion lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO ce_etl.l_data_transFORMATion
VALUES
    ('%'),
    ('%GDP'),
    ('3M3M'),
    ('3M3MA'),
    ('3MA'),
    ('3MYY'),
    ('6MA'),
    ('ABSCH'),
    ('DIX'),
    ('IX'),
    ('LEVEL'),
    ('LVL'),
    ('MM'),
    ('MMA'),
    ('PPTS'),
    ('QA'),
    ('QQ'),
    ('RATIO'),
    ('SDEV'),
    ('YY'),
    ('Z');
