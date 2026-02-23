/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_geo_or_com.sql
 *
 * Validation function - check if GEO/COM code is valid.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_geo_or_com;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_geo_or_com(
    _code TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- Check for nulls
    IF _code IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN 'GEO/COM code cannot be null';
        END IF;
        RETURN NULL;
    END IF;

    -- GEO or COM code
    IF _code ~ '^C.' THEN
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.c_com WHERE code = _code) THEN
            RETURN FORMAT('Commodity code "%s" does not exist', _code);
        ELSEIF EXISTS(SELECT 1 FROM ce_warehouse.c_geo WHERE SUBSTR(_code, 3) = SUBSTR(code, 3)) THEN
            RETURN FORMAT('Commodity SHORT code "%s" cannot match a GEO code', SUBSTR(_code, 3));
        END IF;
    ELSEIF _code ~ '^G.'THEN
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.c_geo WHERE code = _code) THEN
            RETURN FORMAT('Geography code "%s" does not exist', _code);
        ELSEIF EXISTS(SELECT 1 FROM ce_warehouse.c_com WHERE SUBSTR(_code, 3) = SUBSTR(code, 3)) THEN
            RETURN FORMAT('Geography SHORT code "%s" cannot match a COM code', SUBSTR(_code, 3));            END IF;
    ELSE
        RETURN 'Code must start with "C." or "G." for COM or GEO respectively';
    END LOOP;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_geo_or_com
    IS 'Validation function - check if GEO/COM code is valid';
