/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_com_code.sql
 *
 * Validation function - check if COM code is valid (available on Add).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_com_code;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_com_code(
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
            RETURN 'COM code cannot be null';
        END IF;
    ELSEIF _code !~ '^C.' OR LENGTH(_code) < 3 THEN
        RETURN 'COM code should start with "C." prefix and be a min of 3 characters long';
    ELSEIF EXISTS(SELECT 1 FROM ce_warehouse.c_geo WHERE SUBSTR(_code, 3) = SUBSTR(code, 3)) THEN
        RETURN FORMAT('COM SHORT code "%s" cannot match a GEO code', SUBSTR(_code, 3));
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_com_code
    IS 'Validation function - check if COM code is valid  (available on Add)';
