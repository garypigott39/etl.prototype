/*
 ***********************************************************************************************************
 * @file
 * fx_val__pg__is_db.sql
 *
 * Validation/Postgres function - check database name, e.g. to ensure running on specific database only.
 *
 * e.g. IF ce_warehouse.fx_val__pg__is_db('testdb') THEN ...
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__pg__is_db;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__pg__is_db(
    _name TEXT
)
    RETURNS BOOL
    LANGUAGE sql
AS
$$
    SELECT
        CASE WHEN _name IS NULL OR TRIM(_name) = '' THEN FALSE
        ELSE current_database() = _name
        END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__pg__is_db
    IS 'Validation/Postgres function - check current database name, e.g. to ensure running on specific database only.';