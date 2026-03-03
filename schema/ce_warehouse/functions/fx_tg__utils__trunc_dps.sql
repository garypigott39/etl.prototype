/*
 ***********************************************************************************************************
 * @file
 * fx_tg__utils__trunc_dps.sql
 *
 * Trigger function - truncate decimal places (BEFORE update/insert).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__utils__trunc_dps;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__utils__trunc_dps(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _value NUMERIC;
    _colname TEXT;
    _dps INT;
BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    -- Check that a VALUE column & DPD was passed
    IF TG_NARGS < 2 THEN
        RAISE EXCEPTION 'Trigger requires the value column name & decimal places as arguments';
    END IF;
    _colname := TG_ARGV[0];  -- first argument passed to the trigger
    _dps := TG_ARGV[1]::INT;  -- second argument passed to the trigger

    EXECUTE FORMAT(
        'SELECT ($1).%I := trunc(($1).%I, %s)',
        _colname,
        _dps
    )
    INTO _value
    USING NEW;

    IF _value IS NOT NULL THEN
        _value := TRUNC(_value, _dps);
        EXECUTE FORMAT('SELECT ($1).%I := $2', _colname)
            USING NEW, _value;
    END IF;

    RETURN NEW;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__utils__trunc_dps
    IS 'Trigger function - block updates (BEFORE update)';
