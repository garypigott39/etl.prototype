/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_audit_user.sql
 *
 * Validation function - check if audit user is valid.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_audit_user;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_audit_user(
    _value TEXT
)
    RETURNS TEXT
    LANGUAGE sql
AS
$$
SELECT
    CASE
        -- Allow unknown
        WHEN _value = 'unknown' THEN NULL

        -- Check APP user exists
        WHEN _value LIKE 'app:%'
             AND EXISTS (
                 SELECT 1
                 FROM ce_warehouse.l__user u
                 WHERE u.source_uid::TEXT = SPLIT_PART(_value, ':', 2)::TEXT
             )
            THEN NULL

        -- Check SQL user exists
        WHEN _value LIKE 'sql:%'
             AND EXISTS (
                 SELECT 1
                 FROM pg_roles r
                 WHERE r.rolname = SPLIT_PART(_value, ':', 2)
             )
            THEN NULL
        -- Internal users (pk_user < 0) are allowed, but must exist
        WHEN EXISTS (
                SELECT 1
                FROM ce_warehouse.l__user u
                WHERE u.name = _value
                AND pk_user < 0)
            THEN NULL
        ELSE
            FORMAT('Invalid audit user: "%s"', _value)
    END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_audit_user
    IS 'Validation function - check if audit user is valid';
