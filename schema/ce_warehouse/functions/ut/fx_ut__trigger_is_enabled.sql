/*
 ***********************************************************************************************************
 * @file
 * fx_ut__trigger_is_enabled.sql
 *
 * Utility function - check trigger is enabled.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__trigger_is_enabled;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__trigger_is_enabled(
    _name TEXT
)
    RETURNS BOOL
    LANGUAGE sql
AS
$$
    SELECT
        (NOT EXISTS (
            SELECT 1
            FROM ce_warehouse.s__trigger_status
            WHERE name = LOWER(TRIM(_name))
            AND status = 'disabled'
            )
        )::BOOL;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut__trigger_is_enabled
    IS 'Utility function - check trigger is enabled';
