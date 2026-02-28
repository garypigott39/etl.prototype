/*
 ***********************************************************************************************************
 * @file
 * fx_tg_generic__audit.sql
 *
 * Trigger function - log changes to generic audit (AFTER update).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_generic__audit;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_generic__audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _audit_type TEXT := SUBSTRING(TG_OP, 1, 1);  -- 'I', 'U', or 'D'
    _diff JSONB;
    _pk_col TEXT;
    _pk INT;

BEGIN
    -- Check that a PK column was passed
    IF TG_NARGS < 1 THEN
        RAISE EXCEPTION 'Trigger requires the primary key column name as argument';
    END IF;
    _pk_col := TG_ARGV[0];  -- first argument passed to the trigger

    IF TG_OP = 'INSERT' THEN
        _pk := (TO_JSONB(NEW) ->> _pk_col)::TEXT;
        _diff := TO_JSONB(NEW);
    ELSEIF TG_OP = 'UPDATE' THEN
        _pk := (TO_JSONB(NEW) ->> _pk_col)::TEXT;
        _diff := (
            SELECT JSONB_OBJECT_AGG(key, value)
            FROM (
                SELECT key, value
                FROM JSONB_EACH(TO_JSONB(NEW)) AS new(key, value)
                WHERE value IS DISTINCT FROM (TO_JSONB(OLD)->key)
            ) AS changes
        );
    ELSEIF TG_OP = 'DELETE' THEN
        _pk := (TO_JSONB(OLD) ->> _pk_col)::TEXT;
        _diff := TO_JSONB(OLD);
    ELSE
        RETURN NULL;
    END IF;

    INSERT INTO ce_warehouse.a_generic_audit (table_name, table_pk, data, audit_type)
        VALUES (TG_TABLE_NAME, _pk::TEXT, _diff, _audit_type);

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_generic__audit
    IS 'Trigger function - log changes to generic audit (AFTER update)';
