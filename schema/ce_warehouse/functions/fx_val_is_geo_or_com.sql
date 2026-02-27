/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_geo_or_com.sql
 *
 * Validation function - check if pk_geo points to GEO/COM record.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_geo_or_com;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_geo_or_com(
    _pk INT,
    _type TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _like TEXT := (CASE WHEN _type = 'GEO' THEN 'G.%' ELSE 'C.%' END);

BEGIN
    IF _type IS NULL OR _type NOT IN ('GEO', 'COM') THEN
        RAISE EXCEPTION 'Invalid type specified %, should be GEO/COM', _type;
    ELSEIF _pk IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Supplied GEO/primary key cannot be null';
        END IF;
    ELSEIF EXISTS(SELECT 1 FROM ce_warehouse.c_geo WHERE pk_geo = _pk AND code LIKE _like) THEN
        RETURN FORMAT('Supplied GEO/COM primary key is invalid for %s code', _type);
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_geo_or_com
    IS 'Validation function - check if pk_geo points to GEO/COM record';
