/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_ind_codes.sql
 *
 * Validation function - check if IND codes are valid.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_ind_codes;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_ind_codes(
    _indicators TEXT[],
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
    IF ARRAY_LENGTH(_indicators, 1) <> ARRAY_LENGTH(ARRAY(SELECT DISTINCT UNNEST(_indicators)), 1) THEN
        RETURN FALSE;
    END IF;

    -- Check all elements exist in lookup_table
    FOREACH _v IN ARRAY arr LOOP
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.c_ind WHERE code = _v) THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_ind_codes
    IS 'Validation function - check if IND codes are valid';
