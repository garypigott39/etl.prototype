/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_geo_or_com.sql
 *
 * Validation function - check if pk_geo points to GEO/COM record.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_geo_or_com;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_geo_or_com(
    _pk INT,
    _type TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _like TEXT := (CASE WHEN _type = 'geo' THEN 'G.%' ELSE 'C.%' END);

BEGIN
    IF _type IS NULL OR _type NOT IN ('geo', 'com') THEN
        RAISE EXCEPTION 'Invalid type specified %, should be geo/com', _type;
    ELSEIF _pk IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN FORMAT('Supplied "%s" primary key cannot be null', _type);
        END IF;
    ELSEIF NOT EXISTS(SELECT 1 FROM ce_warehouse.c__geo WHERE pk_geo = _pk AND code LIKE _like) THEN
        RETURN FORMAT('Supplied "%s" primary key is invalid', _type);
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_geo_or_com
    IS 'Validation function - check if pk_geo points to GEO/COM record';
