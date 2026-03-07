/*
 ***********************************************************************************************************
 * @file
 * fx_val__pg__is_db_utc.sql
 *
 * Validation/Postgres function - check if database timezone is UTC.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__pg__is_db_utc;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__pg__is_db_utc(
)
    RETURNS TEXT
    LANGUAGE sql
AS
$$
    SELECT
        CASE current_setting('TIMEZONE')
            WHEN 'UTC' THEN
                NULL
            ELSE
                FORMAT(
                        'Invalid database timezone: "%s", expected "UTC"',
                        current_setting('TIMEZONE')
                )
        END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__pg__is_db_utc
    IS 'Validation/Postgres function - checkm if database timezone is UTC';
