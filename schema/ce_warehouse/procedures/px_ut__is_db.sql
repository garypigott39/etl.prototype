/*
 ***********************************************************************************************************
 * @file
 * px_ut__is_db.sql
 *
 * Utility procedure - check current database name, to ensure running on specific database only.
 * Raise EXCEPTION if not running on expected database.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__is_db;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__is_db(
    _db TEXT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF NOT ce_warehouse.fx_ut__is_db(_db) THEN
        RAISE EXCEPTION 'Expected "%", but current database is "%"', _db, CURRENT_DATABASE();
    END IF;
END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__is_db
    IS 'Utility procedure - check current database name, to ensure running on specific database only';