/*
 ***********************************************************************************************************
 * @file
 * fx_tb_schema_perms.sql
 *
 * Pseudo table function - provide a list of users & their schema permissions.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb_schema_perms;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb_schema_perms(
)
    RETURNS TABLE (
        role        NAME,
        schema      NAME,
        can_login   BOOL,
        can_use     BOOL,
        can_create  BOOL,
        owner       BOOL
    )
    LANGUAGE sql
AS
$$
    SELECT
        r.rolname                                            AS role,
        n.nspname                                            AS schema,
		r.rolcanlogin                                        AS can_login,
        has_schema_privilege(r.rolname, n.nspname, 'USAGE')  AS can_use,
        has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS can_create,
		r.oid = n.nspowner                                   AS owner
    FROM pg_roles r
    	CROSS JOIN pg_namespace n
    WHERE n.nspname NOT LIKE 'pg_%'
    AND n.nspname != 'information_schema'
    ORDER BY role, schema;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb_schema_perms
    IS 'Pseudo table function - provide a list of users & their schema permissions';
