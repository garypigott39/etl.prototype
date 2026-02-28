/*
 ***********************************************************************************************************
 * @file
 * fx_tg_block_updates__internal.sql
 *
 * Trigger function - block updates (BEFORE update).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg_block_updates__internal;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg_block_updates__internal(
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

    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        EXECUTE FORMAT('SELECT ($1).%I', _pk_col) INTO _pk USING OLD;
        IF _pk IS NULL THEN
            RAISE EXCEPTION 'Cannot determine record identity for update. Attempted to update record with % = NULL', _pk_col;
        ELSEIF _pk <0 THEN
            RAISE EXCEPTION 'Cannot modify or delete protected record (%.% = %)', TG_TABLE_NAME, _pk_col, _pk;
        END IF;
    END IF;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg_block_updates__internal
    IS 'Trigger function - block updates (BEFORE update)';
