/*
 ***********************************************************************************************************
 * @file
 * fx_tb__seq_check.sql
 *
 * Pseudo table function - compare known sequences (serial keys) with actual values.
 *
 * For list of sequence(s): `SELECT c.relname FROM pg_class c WHERE c.relkind = 'S' order BY c.relname`
 *
 * see https://stackoverflow.com/questions/1493262/list-all-sequences-in-a-postgres-db-8-1-with-sql
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__seq_check;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__seq_check(
)
    RETURNS TABLE (
        table_name TEXT,
        col_name TEXT,
        seq_name TEXT,
        seq_last_value INT,
        col_max_value INT,
        msg TEXT,
        fix TEXT
  )
  LANGUAGE plpgsql
AS
$$
DECLARE
    _rec RECORD;
    _sql TEXT;
    _lv INT;
    _mx INT;

BEGIN
    SET client_min_messages TO WARNING;

    DROP TABLE IF EXISTS t__fx_tb__seq_check;
    CREATE TEMP TABLE t__fx_tb__seq_check
    (
        schema_name TEXT,
        table_name TEXT,
        col_name TEXT,
        seq_name TEXT,
        seq_last_value INT,
        col_max_value INT,
        idx SERIAL NOT NULL
    );

    -- Thanks to ChatGPT for this suggestion to avoid hardcoding the sequence names
    INSERT INTO t__fx_tb__seq_check(schema_name, table_name, col_name, seq_name)
        SELECT
            n.nspname  AS schema_name,
            c.relname  AS table_name,
            a.attname  AS column_name,
            pg_get_serial_sequence(FORMAT('%I.%I', n.nspname, c.relname), a.attname) AS sequence_name
        FROM pg_namespace n
        JOIN pg_class c
          ON c.relnamespace = n.oid
          AND c.relkind = 'r'
        JOIN pg_attribute a
          ON a.attrelid = c.oid
          AND a.attnum > 0
          AND NOT a.attisdropped
        WHERE pg_get_serial_sequence(FORMAT('%I.%I', n.nspname, c.relname), a.attname) IS NOT NULL
        AND n.nspname NOT LIKE 'pg_%'
        AND n.nspname <> 'inFORMATion_schema';

    FOR _rec IN SELECT * FROM t__fx_tb__seq_check
    LOOP
        _sql := 'SELECT last_value FROM ' || _rec.seq_name;
        EXECUTE _sql INTO _lv;
        IF _lv IS NULL THEN
            _lv = 0;
        END IF;

        _sql := 'SELECT MAX(' || _rec.col_name || ') FROM ' || _rec.schema_name || '.' || _rec.table_name;
        EXECUTE _sql INTO _mx;
        IF _mx IS NULL THEN
            _mx := 0;
        END IF;

        UPDATE t__fx_tb__seq_check SET (seq_last_value, col_max_value) = (_lv, _mx) WHERE idx = _rec.idx;
    END LOOP;

    RETURN QUERY(
        SELECT
            t.schema_name || '.' || t.table_name,
            t.col_name,
            t.seq_name,
            t.seq_last_value,
            t.col_max_value,
            CASE
                WHEN t.seq_last_value < t.col_max_value THEN 'Fix required'
                WHEN t.seq_last_value > t.col_max_value THEN 'last_value > max_value, no fix required'
                ELSE '-'
            END,
            CASE
                WHEN t.seq_last_value < t.col_max_value THEN
                    'SELECT SETVAL(''' || t.seq_name || ''', ' || t.col_max_value || ')'
                ELSE NULL
        END
        FROM t__fx_tb__seq_check t
        ORDER BY 1, 2
    );
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__seq_check
    IS 'Pseudo table function - compare known sequences (serial keys) with actual values';
