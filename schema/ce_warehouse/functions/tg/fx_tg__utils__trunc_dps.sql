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

    NEW := JSONB_POPULATE_RECORD(
        NEW,
        JSONB_BUILD_OBJECT(
            _colname,
            TRIM_SCALE(TRUNC((TO_JSONB(NEW)->>_colname)::NUMERIC, _dps))
        )
    );

    RETURN NEW;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__utils__trunc_dps
    IS 'Trigger function - block updates (BEFORE update)';
