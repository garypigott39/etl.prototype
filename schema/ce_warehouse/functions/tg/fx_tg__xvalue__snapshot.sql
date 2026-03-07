/*
 ***********************************************************************************************************
 * @file
 * fx_tg__xvalue__snapshot.sql
 *
 * Trigger function - update values snapshot (AFTER STATEMENT update of x_value).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__xvalue__snapshot;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__xvalue__snapshot(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _rec RECORD;

BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    -- Ignore irrelevant updates
    IF TG_OP = 'UPDATE' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM old_table o
                JOIN new_table n
                    ON n.idx = o.idx
            WHERE (o.fk_pk_series IS DISTINCT FROM n.fk_pk_series)
            OR (o.lk_pk_pdi IS DISTINCT FROM n.lk_pk_pdi)
            OR (o.itype IS DISTINCT FROM n.itype)
            OR (o.value IS NULL AND n.value)
        ) THEN
            RETURN NULL;
        END IF;
    END IF;

    -- Strange edge case where both old and new tables are empty, WTF???
    IF NOT EXISTS (SELECT 1 FROM new_table) AND NOT EXISTS (SELECT 1 FROM old_table) THEN
        RETURN NULL;
    END IF;

    -- Loop through distinct changed slices
    FOR _rec IN
        SELECT DISTINCT
            fk_pk_series,
            ifreq
        FROM (
            SELECT fk_pk_series, ifreq FROM new_table
            UNION
            SELECT fk_pk_series, ifreq FROM old_table
        ) t
    LOOP
        CALL ce_warehouse.px_ut__xsnapshot(
            _rec.fk_pk_series,
            _rec.ifreq
        );
    END LOOP;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__xvalue__snapshot
    IS 'Trigger function - update values snapshot (AFTER STATEMEMNT update of x_value)';
