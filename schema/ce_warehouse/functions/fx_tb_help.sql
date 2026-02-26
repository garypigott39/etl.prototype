/*
 ***********************************************************************************************************
 * @file
 * fx_tb_help.sql
 *
 * Pseudo table function - provide a list of (and document) the database _structure.
 *
 * Thanks to:
 * - https://www.commandprompt.com/education/how-to-list-user-defined-functions-in-postgresql/
 * - https://dba.stackexchange.com/questions/321532/postgresql-script-to-list-all-functions-including-create-date-and-modify-date#321536
 * - https://stackoverflow.com/questions/5664094/getting-list-of-table-comments-in-postgresql#answer-12736192
 * - https://database.guide/3-ways-to-list-all-functions-in-postgresql/
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb_help;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb_help(
)
    RETURNS TABLE (
        schema    NAME,
        name      NAME,
        type      TEXT,
        comments  TEXT,
        full_name TEXT
    )
    LANGUAGE plpgsql
AS
$$
DECLARE
    _regex TEXT := '^ce_';

BEGIN
    RETURN QUERY (
        -- Tables
        SELECT
            table_schema,
            table_name,
            'table' AS type,
            obj_description((table_schema || '.' || table_name)::regclass, 'pg_class') AS comments,
            table_schema || '.' || table_name AS full_name
        FROM information_schema.tables
        WHERE table_schema ~ _regex
        AND table_type = 'BASE TABLE'

        UNION

        -- Views
        SELECT
            table_schema,
            table_name,
            'view',
            obj_description((table_schema || '.' || table_name)::regclass, 'pg_class'),
            table_schema || '.' || table_name
        FROM information_schema.views
        WHERE table_schema ~ _regex

        UNION

        -- Materialized Views
        SELECT
            schemaname,
            matviewname,
            'view.m',
            obj_description((schemaname || '.' || matviewname)::regclass, 'pg_class'),
            schemaname || '.' || matviewname
        FROM pg_matviews
        WHERE schemaname ~ _regex

        UNION

        -- Functions & Procedures
        SELECT
            routine_schema,
            routine_name,
            LOWER(routine_type),
            obj_description((routine_schema || '.' || routine_name)::regproc, 'pg_proc'),
            routine_schema || '.' || routine_name
        FROM information_schema.routines
        WHERE routine_schema ~ _regex
            AND routine_type IN ('FUNCTION', 'PROCEDURE')

        UNION

        -- Triggers, @thanks ChatGPT
        -- If you don't need the description then use much simpler "information_schema.triggers"
        SELECT
            nsp.nspname,                         -- schema name
            tg.tgname || ' ON ' || tbl.relname,  -- trigger name, on table name
            'trigger',
            obj_description(tg.oid, 'pg_trigger'),
            nsp.nspname || '.' || tbl.relname || '::' || tg.tgname
        FROM pg_trigger tg
        JOIN pg_class tbl ON tg.tgrelid = tbl.oid
        JOIN pg_namespace nsp ON tbl.relnamespace = nsp.oid
        WHERE nsp.nspname ~ _regex

        ORDER BY 1, 2, 3
    );
END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb_help
    IS 'Pseudo table function - list of/document the database _structure, based on agreed naming conventions';
