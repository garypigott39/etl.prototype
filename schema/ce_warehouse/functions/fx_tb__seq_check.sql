/*
 ***********************************************************************************************************
 * @file
 * fx_tb__seq_check.sql
 *
 * Pseudo table function - compare known sequences (serial keys) with actual values.
 *
 * For list of sequence(s): `SELECT * FROM pg_sequences` available in Postgres 10+
 *
 * Old version (pre v10):
 *    `SELECT c.relname FROM pg_class c WHERE c.relkind = 'S' order BY c.relname`
 * see https://stackoverflow.com/questions/1493262/list-all-sequences-in-a-postgres-db-8-1-with-sql
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__seq_check;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__seq_check(
)
    RETURNS TABLE (
        table_name     TEXT,
        col_name       TEXT,
        seq_name       TEXT,
        seq_last_value BIGINT,
        col_max_value  BIGINT,
        msg            TEXT,
        fix            TEXT
    )
    LANGUAGE plpgsql
AS
$$
DECLARE
    _rec RECORD;
    _max_count BIGINT;

BEGIN
    CREATE TEMP TABLE t__seq_check (
        t_schema_name TEXT,
        t_table_name TEXT,
        t_col_name TEXT,
        t_seq_name TEXT,
        t_seq_last_value BIGINT,
        t_col_last_value BIGINT
    ) ON COMMIT DROP;

    FOR _rec IN
        SELECT
            n.nspname   AS schema_name,
            c.relname   AS table_name,
            a.attname   AS col_name,
            pg_get_serial_sequence(
                FORMAT('%I.%I', n.nspname, c.relname),
                a.attname
            )           AS seq_name,
            COALESCE(ps.last_value, 0)
                        AS seq_last_value
        FROM pg_namespace n
            JOIN pg_class c
                ON c.relnamespace = n.oid
                AND c.relkind = 'r'
            JOIN pg_attribute a
                ON a.attrelid = c.oid
                AND a.attnum > 0
                AND NOT a.attisdropped
            LEFT JOIN pg_sequences ps
                ON (ps.schemaname || '.' || ps.sequencename) = pg_get_serial_sequence(
                    FORMAT('%I.%I', n.nspname, c.relname),
                    a.attname
                )
        WHERE n.nspname NOT LIKE 'pg_%'
        AND n.nspname <> 'information_schema'
        AND pg_get_serial_sequence(
            FORMAT('%I.%I', n.nspname, c.relname),
            a.attname
            ) IS NOT NULL
    LOOP
        EXECUTE FORMAT('SELECT MAX(%I) FROM %I.%I', _rec.col_name, _rec.schema_name, _rec.table_name)
            INTO _max_count;
        INSERT INTO t__seq_check VALUES (
            _rec.schema_name,
            _rec.table_name,
            _rec.col_name,
            _rec.seq_name,
            _rec.seq_last_value,
            COALESCE(_max_count, 0)
        );
    END LOOP;

    RETURN QUERY (
        SELECT
            t_schema_name || '.' || t_table_name,
            t_col_name,
            t_seq_name,
            t_seq_last_value,
            t_col_last_value,
            CASE
                WHEN t_seq_last_value < t_col_last_value THEN
                    'Fix required'
                WHEN t_seq_last_value > t_col_last_value THEN
                    'last_value > max_value, no fix required'
                ELSE '-'
            END,
            CASE
                WHEN t_seq_last_value < t_col_last_value THEN
                    FORMAT('SELECT setval(''%s'', %s);', seq_name, col_max_value)
                ELSE NULL
            END
        FROM t__seq_check
        ORDER BY 1, 2
    );
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__seq_check
    IS 'Pseudo table function - compare known sequences (serial keys) with actual values';
