/*
 ***********************************************************************************************************
 * @file
 * fx_tg_c_series__soft_delete.sql
 *
 * Trigger function - soft delete on c_series record (BEFORE DELETE).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_c_series__soft_delete;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_c_series__soft_delete(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    -- Prevent execution if tiggered by another trigger
    IF pg_trigger_depth() > 1 THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    IF OLD.status = 'deleted' THEN
        -- Already marked as deleted, nothing to do, but also prevents infinite loop
        RETURN NULL;
    ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.x_value WHERE fk_pk_series = OLD.pk_series) THEN
        -- No values allow deletion to proceed as normal
        RETURN OLD;
    END IF;

    UPDATE ce_warehouse.c_series
    SET status = 'deleted',
        updated_utc = NOW()
    WHERE pk_series  = OLD.pk_series;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_c_series__soft_delete
    IS 'Trigger function - soft delete on c_series record (BEFORE DELETE)';
