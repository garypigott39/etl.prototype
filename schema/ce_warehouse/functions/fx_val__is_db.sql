/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_db.sql
 *
 * Validation function - check database name, e.g. to ensure running on specific database only.
 *
 * e.g. IF ce_warehouse.fx_val__is_db('testdb') THEN ...
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_db_utc;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_db_utc(
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

COMMENT ON FUNCTION ce_warehouse.fx_val__is_db
    IS 'Validation function - check current database name, e.g. to ensure running on specific database only.';