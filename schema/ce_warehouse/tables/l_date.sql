/*
 ***********************************************************************************************************
 * @file
 * l_date.sql
 *
 * Lookup table - date lookup. System generated.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l_date;

CREATE TABLE IF NOT EXISTS ce_warehouse.l_date
(
    pk_dti INT NOT NULL GENERATED ALWAYS
        AS (ce_warehouse.fx_ut_date_to_dti(date)) STORED,

    date DATE NOT NULL,

    PRIMARY KEY (pk_dti),
    UNIQUE (date)
);

COMMENT ON TABLE ce_warehouse.l_date
    IS 'Lookup table - date lookup. System generated';
