/*
 ***********************************************************************************************************
 * @file
 * fx_tb_schema_perms.sql
 *
 * Pseudo table function - provide a list of users & their schema permissions.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_core.fx_tb_schema_perms;

CREATE OR REPLACE FUNCTION ce_core.fx_tb_schema_perms(
)
    RETURNS TABLE (
        role        NAME,
        schema      NAME,
        can_use     BOOLEAN,
        can_create  BOOLEAN
    )
    LANGUAGE sql
AS
$$
    SELECT
        r.rolname AS role,
        n.nspname AS schema,
        has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS can_use,
        has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS can_create
    FROM pg_roles r
    CROSS JOIN pg_namespace n
    WHERE r.rolcanlogin = true
    AND n.nspname NOT LIKE 'pg_%'
    AND n.nspname != 'information_schema'
    ORDER BY role, schema;
$$;

COMMENT ON FUNCTION ce_core.fx_tb_schema_perms
    IS 'Pseudo table function - provide a list of users & their schema permissions';
