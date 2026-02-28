/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_active.sql
 *
 * Validation function - check if parent (series/geo or com/ind) is active.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_active;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_active(
    _code TEXT,
    _type TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _status TEXT;

BEGIN
    IF _type IS NULL OR _type NOT IN ('series', 'geo', 'ind') THEN
        RAISE EXCEPTION 'Invalid type specified %, should be series/geo/ind', _type;
    ELSEIF _code IS NULL OR TRIM(_code) = '' THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Supplied code cannot be null';
        END IF;
    ELSEIF _type = 'geo' THEN
        _status := (SELECT status FROM ce_warehouse.c_geo WHERE code = _code LIMIT 1);
        IF _status IS NULL THEN
            RETURN FORMAT('Supplied GEO code %s is invalid', _code);
        ELSEIF _status = 'deleted' THEN
            RETURN FORMAT('Supplied GEO code %s is marked as deleted', _code);
        END IF;
    ELSEIF _type = 'ind' THEN
        _status := (SELECT status FROM ce_warehouse.c_ind WHERE code = _code LIMIT 1);
        IF _status IS NULL THEN
            RETURN FORMAT('Supplied IND code %s is invalid', _code);
        ELSEIF _status = 'deleted' THEN
            RETURN FORMAT('Supplied IND code %s is marked as deleted', _code);
        END IF;
    ELSEIF _type = 'series' THEN
        _status := (SELECT status FROM ce_warehouse.c_series WHERE series_id = _code LIMIT 1);
        IF _status IS NULL THEN
            RETURN FORMAT('Supplied SERIES ID %s is invalid', _code);
        ELSEIF _status = 'deleted' THEN
            RETURN FORMAT('Supplied SERIES ID %s is marked as deleted', _code);
        END IF;
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_active
    IS 'Validation function - check if pk_geo points to GEO/COM record';
