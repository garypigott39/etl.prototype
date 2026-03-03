/*
 ***********************************************************************************************************
 * @file
 * fx_tg__xgen__audit.sql
 *
 * Trigger function - generic audit trigger (AFTER update).
 *
 * NOTE, this is a generic function that can be used for any table - the PK column name must be passed as
 * an argument when creating the trigger.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__xgen__audit;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__xgen__audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _audit_type TEXT := SUBSTRING(TG_OP, 1, 1);  -- 'I', 'U', or 'D'
    _new JSONB;
    _old JSONB;
    _diff JSONB;
    _pk_col TEXT;
    _pk TEXT;

BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    -- Check that a PK column was passed
    IF TG_NARGS < 1 THEN
        RAISE EXCEPTION 'Trigger requires the primary key column name as argument';
    END IF;
    _pk_col := TG_ARGV[0];  -- first argument passed to the trigger

    CASE TG_OP
        WHEN 'INSERT' THEN
            _new := TO_JSONB(NEW);
            _old := _new;
            _diff := _new;  -- for inserts, the diff is just the new record
        WHEN 'UPDATE' THEN
            _new := TO_JSONB(NEW);
            _old := TO_JSONB(OLD);
            _diff := (
                SELECT JSONB_OBJECT_AGG(key, value)
                FROM (
                    SELECT key, value
                    FROM JSONB_EACH(_new) AS new(key, value)
                    WHERE value IS DISTINCT FROM (_old->key)
                ) AS changes
            );
        WHEN 'DELETE' THEN
            _old := TO_JSONB(OLD);
            _diff := _old;
        ELSE
            RETURN NULL;  -- unsupported operation
    END CASE;

    _pk := (_old ->> _pk_col)::TEXT;
    IF _pk IS NULL THEN
        RAISE EXCEPTION 'Cannot determine record identity for audit. Attempted to audit record with % = NULL', _pk_col;
    END IF;

    IF _diff IS NOT NULL THEN
        INSERT INTO ce_warehouse.a__xgen_audit (
            t_name, t_pkey, data, audit_type, audit_user
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            _pk,
            _diff,
            _audit_type,
            ce_warehouse.fx_ut__get_current_uid()
        );
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__xgen__audit
    IS 'Trigger function - generic audit trigger (AFTER update)';
