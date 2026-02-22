/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_geo_groups.sql
 *
 * Validation function - check if GEO group codes are valid.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_geo_groups;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_geo_groups(
    _groups TEXT[],
    _nulls_allowed BOOL DEFAULT FALSE
)
    RETURNS BOOL
    LANGUAGE plpgsql
AS
$$
DECLARE
    _v TEXT;
BEGIN
    -- Check for duplicates
    IF ARRAY_LENGTH(_groups, 1) <> ARRAY_LENGTH(ARRAY(SELECT DISTINCT UNNEST(_groups)), 1) THEN
        RETURN FALSE;
    END IF;

    -- Check all elements exist in lookup_table
    FOREACH _v IN ARRAY _groups
    LOOP
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.l_geo_groups WHERE code = _v) THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_geo_groups
    IS 'Validation function - check if GEO group codes are valid';
