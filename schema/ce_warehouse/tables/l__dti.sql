/*
 ***********************************************************************************************************
 * @file
 * l_date.sql
 *
 * Lookup table - date lookup. System generated.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.l__dti;

CREATE TABLE IF NOT EXISTS ce_warehouse.l__dti
(
    pk_dti INT NOT NULL GENERATED ALWAYS
        AS (ce_warehouse.fx_ut__date_to_pdi_or_dti(dt_date, -1)) STORED,

    dt_date DATE NOT NULL,

    PRIMARY KEY (pk_dti),
    UNIQUE (dt_date)
);

COMMENT ON TABLE ce_warehouse.l__dti
    IS 'Lookup table - date lookup. System generated';
