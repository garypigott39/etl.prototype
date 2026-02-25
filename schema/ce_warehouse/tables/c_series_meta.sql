/*
 ***********************************************************************************************************
 * @file
 * c_series_meta.sql
 *
 * Control table - series metadata, including system generated/triggered data.
 *
 * Note, linked to parent series + partially maintained by trigger updates.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.c_series_meta;

CREATE TABLE IF NOT EXISTS ce_warehouse.c_series_meta
(
    pk_series_meta INT GENERATED ALWAYS
        AS (((ifreq * 10) + itype) * 1000000 + fk_pk_series) STORED,  -- derived UNIQUE key!!
    fk_pk_series INT NOT NULL
        REFERENCES ce_warehouse.c_series (pk_series)
            ON UPDATE CASCADE
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED,
    ifreq SMALLINT NOT NULL
        CHECK (ifreq IN (1, 2, 3, 4, 5)),
    itype SMALLINT NOT NULL,
        CHECK (itype IN (1, 2)),

    -- Auto generated fields
    sid2 TEXT NOT NULL GENERATED ALWAYS
        AS (ce_warehouse.fx_ut_sid_2_3(fk_pk_series, ifreq)) STORED,
    sid3 TEXT NOT NULL GENERATED ALWAYS
        AS (ce_warehouse.fx_ut_sid_2_3(fk_pk_series, ifreq, itype)) STORED,

    -- User maintained fields
    downloadable TEXT NOT NULL DEFAULT 'ess_plugin'
        CHECK (downloadable IN ('all', 'api', 'adv_plugin', 'ess_plugin', 'internal', 'none', 'powerbi')),  -- control which series are downloadable and via which channels
    forecast_only_lifespan INT,  -- If NULL then will take the system default
    internal_notes TEXT,  -- Unvalidated!

    -- UPDATED via trigger etc
    first_pdi INT,
    last_pdi INT,

    has_values BOOL NOT NULL DEFAULT FALSE,  -- flag to indicate if there are any values for this series/frequency/type
    new_values_utc TIMESTAMPTZ,  -- timestamp of the most recent new value
    updated_values_utc TIMESTAMPTZ,  -- timestamp of the most recent updated (or deleted) value

    updated_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (pk_series_meta),
    UNIQUE (fk_pk_series, ifreq, itype)
);

COMMENT ON TABLE ce_warehouse.c_series_meta
    IS 'Control table - series metadata, including system generated/triggered data';
