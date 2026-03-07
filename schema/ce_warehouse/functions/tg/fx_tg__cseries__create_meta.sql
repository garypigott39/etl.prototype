/*
 ***********************************************************************************************************
 * @file
 * fx_tg__cseries__create_meta.sql
 *
 * Trigger function - create metadata records on c_series table INSERTs.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__cseries__create_meta;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__cseries__create_meta(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO ce_warehouse.c__series_meta (fk_pk_series, sid1, ifreq, itype)
            SELECT
                NEW.pk_series,
                NEW.sid1,
                f.pk_freq,
                t.pk_type
            FROM ce_warehouse.l__freq f
                CROSS JOIN ce_warehouse.l__type t
            ORDER BY 1, 3, 4
        ON CONFLICT (sid3)
            DO NOTHING;
    END IF;

    -- No need to return a record since this is an AFTER trigger
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__cseries__create_meta
    IS 'Trigger function - create metadata records on c_series table INSERTs';
