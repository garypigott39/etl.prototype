/*
 ***********************************************************************************************************
 * @file
 * fx_tb__help.sql
 *
 * Pseudo table function - list/document database structure (named schemas).
 *
 * Thanks to:
 * - https://www.commandprompt.com/education/how-to-list-user-defined-functions-in-postgresql/
 * - https://dba.stackexchange.com/questions/321532/postgresql-script-to-list-all-functions-including-create-date-and-modify-date#321536
 * - https://stackoverflow.com/questions/5664094/getting-list-of-table-comments-in-postgresql#answer-12736192
 * - https://database.guide/3-ways-to-list-all-functions-in-postgresql/
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__help;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__help(
    _regex TEXT DEFAULT '^ce_'
)
    RETURNS TABLE (
        type       TEXT,
        schema     NAME,
        name       NAME,
        tigger_on  TEXT,
        comments   TEXT,
        full_name  TEXT
    )
    LANGUAGE sql
AS
$$
    WITH _objects AS (
        -- Tables, Views, MatViews
        SELECT
            CASE c.relkind
                WHEN 'r' THEN 'table'
                WHEN 'v' THEN 'view'
                WHEN 'm' THEN 'view.m'
            END                                 AS type,
            n.nspname                           AS schema,
            c.relname                           AS name,
            '-'                                 AS tigger_on,
            obj_description(c.oid, 'pg_class')  AS comments,
            n.nspname || '.' || c.relname       AS full_name
        FROM pg_class c
            JOIN pg_namespace n
                ON n.oid = c.relnamespace
        WHERE n.nspname ~ _regex
        AND c.relkind IN ('r', 'v', 'm')
        UNION ALL

        -- Functions & Procedures
        SELECT
            CASE LOWER(p.prokind::text)
                WHEN 'p' THEN 'procedure'
                ELSE 'function'
            END,
            n.nspname,
            p.proname,
            '-',
            obj_description(p.oid, 'pg_proc'),
            n.nspname || '.' || p.proname
        FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
        WHERE n.nspname ~ _regex
        AND p.prokind IN ('f', 'p')
        UNION ALL

        -- Triggers
        SELECT
            'trigger',
            n.nspname,
            t.tgname,
            c.relname,
            obj_description(t.oid, 'pg_trigger'),
            t.tgname || ' ON ' || n.nspname || '.' || c.relname
        FROM pg_trigger t
            JOIN pg_class c
                ON c.oid = t.tgrelid
            JOIN pg_namespace n
                ON n.oid = c.relnamespace
        WHERE n.nspname ~ _regex
        AND NOT t.tgisinternal
    )
    SELECT *
    FROM _objects
    ORDER BY 1, 2, 3, 4;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__help
    IS 'Pseudo table function - list/document database structure (named schemas)';
