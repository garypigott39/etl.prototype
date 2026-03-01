/*
 ***********************************************************************************************************
 * @file
 * fx_tg__cind__soft_delete.sql
 *
 * Trigger function - soft delete on c_ind record (BEFORE DELETE).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__cind__soft_delete;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__cind__soft_delete(
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
    ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.c__series WHERE fk_pk_ind = OLD.pk_ind) THEN
        -- No values allow deletion to proceed as normal
        RETURN OLD;
    END IF;

    UPDATE ce_warehouse.c__ind
    SET status = 'deleted',
        ts_updated = NOW()
    WHERE pk_ind  = OLD.pk_ind;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__cind__soft_delete
    IS 'Trigger function - soft delete on c_ind record (BEFORE DELETE)';
