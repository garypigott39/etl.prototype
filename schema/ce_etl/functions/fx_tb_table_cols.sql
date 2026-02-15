/*
 ***********************************************************************************************************
 * @file
 * fx_tb_table_cols.sql
 *
 * Pseudo table function - provide a list of column names in named table.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_tb_table_cols;

CREATE OR REPLACE FUNCTION ce_etl.fx_tb_table_cols(
    _tablename TEXT,
    _schema TEXT,
    _ignore TEXT[] DEFAULT NULL
)
    RETURNS TABLE (
        column_name NAME
    )
    LANGUAGE plpgsql
AS
$$

BEGIN
    RETURN QUERY(
        SELECT
            schema.column_name::NAME
        FROM information_schema.columns schema
        WHERE schema.table_name = _tablename
        AND schema.table_schema = _schema
        AND schema.table_catalog = CURRENT_DATABASE()
        AND (_ignore IS NULL OR ARRAY_POSITION(_ignore, schema.column_name::TEXT) IS NULL)
        ORDER BY
           schema.ordinal_position
    );
END
$$;

COMMENT ON FUNCTION ce_etl.fx_tb_table_cols
    IS 'Pseudo table function - provide a list of columns in named table';
