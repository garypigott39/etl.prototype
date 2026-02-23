/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_geo_code.sql
 *
 * Validation function - check if GEO code is valid (available on Add).
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
            RETURN 'GEO code cannot be null';
        END IF;
    ELSEIF _code !~ '^G.' OR LENGTH(_code) < 3 THEN
        RETURN 'GEO code should start with "G." prefix and be a min of 3 characters long';
    ELSEIF EXISTS(SELECT 1 FROM ce_warehouse.c_com WHERE SUBSTR(_code, 3) = SUBSTR(code, 3)) THEN
        RETURN FORMAT('GEO SHORT code "%s" cannot match a COM code', SUBSTR(_code, 3));
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_geo_code
    IS 'Validation function - check if GEO code is valid  (available on Add)';
