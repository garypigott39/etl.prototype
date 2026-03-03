/*
 ***********************************************************************************************************
 * @file
 * px_ut__sync_users.sql
 *
 * Utility procedure - sync Django users into warehouse.
 *
 * NOTE, relies on using the following groups in Django to determine user permissions:
 * - DATA TEAM: users with access to data team features
 * - VALUE UPLOADER: users with access to financial upload features
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__sync_users;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__sync_users(
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    CREATE TEMP TABLE t__django_users
        ON COMMIT DROP
        AS
        SELECT
            u.id                                AS source_uid,
            TRIM(u.username)                    AS name,
            CASE u.is_active
                WHEN TRUE THEN 'active'
                ELSE 'inactive'
            END                                 AS status,
            u.is_superuser                      AS is_admin,
            COALESCE(
                ARRAY_AGG(UPPER(g.name))
                FILTER (WHERE g.name IS NOT NULL),
                '{}'
            )                                   AS groups
        FROM public.auth_user u
            LEFT JOIN public.auth_user_groups ug
                ON ug.user_id = u.id
            LEFT JOIN public.auth_group g
                ON ug.user_id = u.id
        GROUP BY 1, 2, 3, 4
        ORDER BY 1;

    /*
     ****************************************************************************************
     * Insert new users from Django or reactivate previously deleted users
     ****************************************************************************************
     */
    INSERT INTO ce_warehouse.l__user (
        name, status, source_uid, is_admin
    )
        SELECT
            t.name,
            t.status,
            t.source_uid,
            t.is_admin
        FROM t__django_users t
            LEFT JOIN ce_warehouse.l__user u
                ON u.source_uid = t.source_uid
        WHERE u.source_uid IS NULL;

    -- Reactivate previously deleted users if they exist in Django
    UPDATE ce_warehouse.l__user u
        SET status = 'active',
            is_admin = t.is_admin
    FROM t__django_users t
    WHERE u.source_uid = t.source_uid
    AND u.status = 'deleted'
    AND u.pk_user > 0;  -- do not touch system users

    /*
     ****************************************************************************************
     * Mark users as deleted if they no longer exist in Django
     ****************************************************************************************
     */
    UPDATE ce_warehouse.l__user u
        SET status = 'deleted'
    WHERE NOT EXISTS (
        SELECT 1
        FROM t__django_users t
        WHERE t.source_uid = u.source_uid
    )
    AND u.status <> 'deleted'
    AND u.pk_user > 0;  -- do not touch system users

    /*
     ****************************************************************************************
     * Update is_admin, is_data_team, is_value_uploader flags for existing users based on
     * Django data
     ****************************************************************************************
     */
    UPDATE ce_warehouse.l__user u
        SET is_admin = t.is_admin,
            is_data_team = 'DATA TEAM' = ANY(t.groups),
            is_value_uploader = 'VALUE UPLOADER' = ANY(t.groups),
            is_check_uploads = 'CHECK UPLOADS' = ANY(t.groups)
    FROM t__django_users t
    WHERE u.source_uid = t.source_uid
    AND u.status <> 'deleted'
    AND u.pk_user > 0;  -- do not touch system users

END;
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__sync_users
    IS 'Utility procedure - sync Django users into warehouse';
