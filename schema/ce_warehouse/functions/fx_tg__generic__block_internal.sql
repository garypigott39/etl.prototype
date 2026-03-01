/*
 ***********************************************************************************************************
 * @file
 * fx_tg__generic__block_internal.sql
 *
 * Trigger function - block updates (BEFORE update).
 * CONSTRAINT TRIGGER.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__generic__block_internal;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__generic__block_internal(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _pk_col TEXT;
    _pk INT;
BEGIN
    -- Check that a PK column was passed
    IF TG_NARGS < 1 THEN
        RAISE EXCEPTION 'Trigger requires the primary key column name as argument';
    END IF;
    _pk_col := TG_ARGV[0];  -- first argument passed to the trigger

    IF TG_OP = 'INSERT' THEN
       RETURN NEW;  -- allow inserts
    END IF;

    EXECUTE FORMAT('SELECT ($1).%I', _pk_col) INTO _pk USING OLD;
    IF _pk IS NULL THEN
        RAISE EXCEPTION 'Cannot determine record identity for update. Attempted to update record with % = NULL', _pk_col;
    ELSEIF _pk < 0 THEN
        RAISE EXCEPTION 'Cannot modify or delete protected record (%.% = %)', TG_TABLE_NAME, _pk_col, _pk;
    ELSEIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__generic__block_internal
    IS 'Trigger function - block updates (BEFORE update)';
