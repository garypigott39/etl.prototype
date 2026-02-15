/*
 ***********************************************************************************************************
 * @file
 * l_data_transformation.sql
 *
 * Lookup table - data transformation lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS core.l_data_transformation;

CREATE TABLE IF NOT EXISTS core.l_data_transformation
(
    code TEXT NOT NULL,
    PRIMARY KEY (code),
);

COMMENT ON TABLE core.l_data_transformation
    IS 'Lookup table - data transformation lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO core.l_data_transformation
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
