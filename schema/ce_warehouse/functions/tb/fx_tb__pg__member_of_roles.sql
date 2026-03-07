/*
 ***********************************************************************************************************
 * @file
 * fx_tb__pg__member_of_roles.sql
 *
 * Pseudo/Postgres table function - provide a list of users (role members) & their roles.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__pg__member_of_roles;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__pg__member_of_roles(
)
    RETURNS TABLE (
        user_name   NAME,
        member_of   NAME
    )
    LANGUAGE sql
AS
$$
    SELECT
        r.rolname   AS user_name,
        g.rolname   AS member_of
    FROM pg_auth_members m
        JOIN pg_roles r ON m.member = r.oid
        JOIN pg_roles g ON m.roleid = g.oid
    ORDER BY 1, 2;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__pg__member_of_roles
    IS 'Pseudo/Postgres table function - provide a list of users (role members) & their roles';
