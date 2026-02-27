/*
 ***********************************************************************************************************
 * @file
 * s_sys_flags.sql
 *
 * System table - assorted system flags.
 *
 * NOTE, we don't use the text validation functions in any of the "s_" system tables because they are
 * potentially used by the validation functions, so we need to have more basic validation rules in place
 * to avoid circular references.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.s_sys_flags;

CREATE TABLE IF NOT EXISTS ce_warehouse.s_sys_flags
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Z][A-Z0-9 _/:\.+-]*[A-Z0-9]$'),
    value TEXT NOT NULL,
    description TEXT NOT NULL,

    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.s_sys_flags
    IS 'System table - assorted system flags';

/**
 * Pre-populate with known values.
 */
INSERT INTO ce_warehouse.s_sys_flags (code, value, description)
VALUES
    ('ASCII-ONLY','FALSE','If set to "TRUE" then only allow ASCII text values. Default is value is "FALSE".'),
    ('DATE.MAX','+30 YEAR','Max date for date lookup table. This should be an INTERVAL value. Default is "+30 YEAR".'),
    ('DATE.MIN','1890-01-01','Minimum date for date lookup table, should be the beginning of a year'),
    ('GEO.FLAG.BASEURL','https://www.capitaleconomics.com/sites/default/files/','Base URL for GEO flags. Note the trailing slash.'),
    ('PIPELINE.ERRCTL', 'SKIP', 'Pipeline errors, what to do with control table errors. Options are SKIP (default), or ABORT.');
