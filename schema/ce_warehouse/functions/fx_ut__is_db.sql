/*
 ***********************************************************************************************************
 * @file
 * fx_ut__is_db.sql
 *
 * Utility function - check database name, to ensure running on specific database only.
 *
 * e.g. IF ce_warehouse.fx_ut__is_db('testdb') THEN ...
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__is_db;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__is_db(
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

COMMENT ON FUNCTION ce_warehouse.fx_ut__is_db
    IS 'Utility function - check current database name';