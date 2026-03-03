/*
 ***********************************************************************************************************
 * @file
 * fx_tg__utils__block.sql
 *
 * Trigger function - block designated action.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__utils__block;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__utils__block(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    RAISE EXCEPTION 'Action %s on table %s is NOT allowed', TG_OP, TG_TABLE_NAME;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__utils__block_internal
    IS 'Trigger function - block designated actioon';
