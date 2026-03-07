/*
 ***********************************************************************************************************
 * @file
 * fx_ut__to_dps.sql
 *
 * Utility function - truncate (or round) to N decimal places.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut__to_dps;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut__to_dps(
    _val NUMERIC,
    _dps INT DEFAULT 2,
    _action TEXT DEFAULT 'trunc'
)
    RETURNS NUMERIC
    LANGUAGE sql
    IMMUTABLE
    STRICT
AS
$$
    SELECT
        CASE _action
            WHEN 'trunc' THEN
                TRIM_SCALE(TRUNC(_val, _dps))
            WHEN 'round' THEN
                ROUND(_val, _dps)
            ELSE NULL
        END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut__to_dps
    IS 'Utility function - truncate (or round) to N decimal places';
