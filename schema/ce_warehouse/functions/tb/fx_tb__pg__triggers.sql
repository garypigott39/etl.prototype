/*
 ***********************************************************************************************************
 * @file
 * fx_tb__pg__triggers.sql
 *
 * Pseudo table function - provide a list of triggers & the functions they call.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__pg__triggers;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__pg__triggers(
    _schema TEXT = '^ce_'
)
    RETURNS TABLE (
        tg_name NAME,
        func_name NAME,
        schema NAME
    )
    LANGUAGE sql
AS
$$
    SELECT
        t.tgname    AS tg_name,
        p.proname   AS func_name,
        n.nspname   AS schema
    FROM pg_trigger t
        JOIN pg_proc p
            ON t.tgfoid = p.oid
        JOIN pg_namespace n
            ON p.pronamespace = n.oid
    WHERE n.nspname ~ _schema
    AND NOT t.tgisinternal
    ORDER BY
        1, 2;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__pg__triggers
    IS 'Pseudo table function - provide a list of triggers & the functions they call';
