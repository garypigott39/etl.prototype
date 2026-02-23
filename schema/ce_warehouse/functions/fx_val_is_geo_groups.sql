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
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _v TEXT;
BEGIN
    -- Check for nulls
    IF _groups IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN 'GEO group codes cannot be null';
        END IF;
        RETURN NULL;
    END IF;

    -- Check for duplicates
    IF ARRAY_LENGTH(_groups, 1) <> ARRAY_LENGTH(ARRAY(SELECT DISTINCT UNNEST(_groups)), 1) THEN
        RETURN 'Duplicate GEO group codes are not allowed';
    END IF;

    -- Check all elements exist in GEO group lookup table
    FOREACH _v IN ARRAY _groups
    LOOP
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.l_geo_groups WHERE code = _v) THEN
            RETURN FORMAT('GEO group code "%s" does not exist', _v);
        END IF;
    END LOOP;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_geo_groups
    IS 'Validation function - check if GEO group codes are valid';
