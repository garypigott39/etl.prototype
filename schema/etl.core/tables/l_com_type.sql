/*
 ***********************************************************************************************************
 * @file
 * l_com_type.sql
 *
 * Lookup table - frequency lookup.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS core.l_com_type;

CREATE TABLE IF NOT EXISTS core.l_com_type
(
    code TEXT NOT NULL CHECK (code ~ '^[A-Z][a-z0-9 ]*$'), -- Single uppercase letter
    PRIMARY KEY (id),
);

COMMENT ON TABLE core.l_com_type
    IS 'Lookup table - commodity type lookup';

/**
 * Pre-populate with known values. Update as required.
 */
INSERT INTO core.l_com_type
VALUES
('Agriculturals'),
('Commodity index'),
('Energy'),
('Industrial metals'),
('Precious metals');