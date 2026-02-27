/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_geo_code.sql
 *
 * Validation function - check if GEO/COM code is valid (in GEO table).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_geo_code;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_geo_code(
    _code TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _code IS NULL OR TRIM(_code) = '' THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Code cannot be null';
        END IF;
    ELSEIF NOT EXISTS(SELECT 1 FROM ce_warehouse.c_geo WHERE code = _code) THEN
        RETURN FORMAT('GEO/COM code "%s" does not exist in c_geo table', _code);
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_geo_code
    IS 'Validation function - check if GEO/COM code is valid  (available on Add)';
