/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_ind_codes.sql
 *
 * Validation function - check if IND codes are valid.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_ind_codes;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_ind_codes(
    _indicators TEXT[],
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
    IF _indicators IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN 'IND codes cannot be null';
        END IF;
        RETURN NULL;
    END IF;

    -- Check for duplicates
    IF ARRAY_LENGTH(_indicators, 1) <> ARRAY_LENGTH(ARRAY(SELECT DISTINCT UNNEST(_indicators)), 1) THEN
        RETURN 'Duplicate IND codes are not allowed';
    END IF;

    -- Check all elements exist in IND lookup table
    FOREACH _v IN ARRAY arr LOOP
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.c__ind WHERE code = _v) THEN
            RETURN FORMAT('IND code "%s" does not exist', _v);
        END IF;
    END LOOP;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_ind_codes
    IS 'Validation function - check if IND codes are valid';
