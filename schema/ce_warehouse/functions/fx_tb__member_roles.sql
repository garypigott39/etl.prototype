/*
 ***********************************************************************************************************
 * @file
 * fx_tb__member_roles.sql
 *
 * Pseudo table function - provide a list of users (role members) & their roles.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__member_roles;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__member_roles(
)
    RETURNS TABLE (
        member      NAME,
        role        NAME
    )
    LANGUAGE sql
AS
$$
    SELECT
        r.rolname AS member,
        g.rolname AS role
    FROM pg_auth_members m
    JOIN pg_roles r ON m.member = r.oid
    JOIN pg_roles g ON m.roleid = g.oid
    ORDER BY 1, 2;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__member_roles
    IS 'Pseudo table function - provide a list of users (role members) & their roles';
