/*
 ***********************************************************************************************************
 * @file
 * fx_tb__table_cols.sql
 *
 * Pseudo table function - provide a list of column names in named table.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__table_cols;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__table_cols(
    _tablename TEXT,
    _schema TEXT,
    _ignore TEXT[] DEFAULT NULL
)
    RETURNS TABLE (
        column_name NAME
    )
    LANGUAGE sql
AS
$$
    SELECT s.column_name::NAME
    FROM information_schema.columns s
    WHERE s.table_name   = _tablename
    AND s.table_schema = _schema
    AND s.table_catalog = CURRENT_DATABASE()
    AND (
        _ignore IS NULL OR s.column_name <> ALL (_ignore)
    )
    ORDER BY s.ordinal_position;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__table_cols
    IS 'Pseudo table function - provide a list of columns in named table';
