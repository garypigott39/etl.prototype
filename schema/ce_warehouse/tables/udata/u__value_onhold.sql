/*
 ***********************************************************************************************************
 * @file
 * u_value_onhold.sql
 *
 * Userdata table - datapoint values awaiting "approval" or "rejection".
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.u__value_onhold;

CREATE TABLE IF NOT EXISTS ce_warehouse.u__value_onhold
(
    idx INT GENERATED ALWAYS AS IDENTITY,

    fk_pk_series INT NOT NULL
        REFERENCES ce_warehouse.c__series (pk_series)
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED
        CHECK (fk_pk_series > 0),
    lk_pk_pdi INT NOT NULL
        REFERENCES ce_warehouse.l__period (pk_pdi)
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED,  
    ifreq SMALLINT NOT NULL GENERATED ALWAYS
        AS (lk_pk_pdi / 100000000) STORED
        CHECK (ifreq IN (1, 2, 3 , 4, 5)),  -- extract frequency from period code
    itype SMALLINT NOT NULL
        CHECK (itype IN (1, 2)),  -- enforce valid types: 1=actual, 2=forecast
    lk_pk_source INT NOT NULL
        REFERENCES ce_warehouse.l__source (pk_source)
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED,
    value NUMERIC NOT NULL,
    tooltip TEXT,

    update_type TEXT,  -- NEW, UPDATE, DELETE or UNCHANGED

    uploaded_by INT NOT NULL
        REFERENCES ce_warehouse.l__user (pk_user)
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED,

    is_api BOOL NOT NULL,  -- flag to indicate if the value is from an API (set via manual loader)

    file_name TEXT,
    onhold_reason TEXT,  -- system generated

    ts_created TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (idx)
);

-- It's recommended to have INDICES on foreign keys for performance!! (particularly important for large tables)
CREATE INDEX IF NOT EXISTS u__value_onhold__series__idx
    ON ce_warehouse.u__value_onhold (fk_pk_series);

CREATE INDEX IF NOT EXISTS u__value_onhold__pdi__idx
    ON ce_warehouse.u__value_onhold (lk_pk_pdi);

CREATE INDEX IF NOT EXISTS u__value_onhold__source__idx
    ON ce_warehouse.u__value_onhold (lk_pk_source);

CREATE INDEX IF NOT EXISTS u__value_onhold__uploaded_by__idx
    ON ce_warehouse.u__value_onhold (uploaded_by);

COMMENT ON TABLE ce_warehouse.u__value_onhold
    IS 'Userdata table - datapoint values awaiting "approval" or "rejection"';