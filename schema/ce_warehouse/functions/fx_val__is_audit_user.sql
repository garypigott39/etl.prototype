/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_audit_user.sql
 *
 * Validation function - check if audit user is (kind of) valid.
 *
 * Note, we cant check against the l__user table because we end up with circular dependencies!!
 * and this is only used for auditing annotation...
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
        -- Allow unknown/system/migration
        WHEN _value IN ('unknown', 'system', 'migration') THEN NULL

        -- Check SQL user exists
        WHEN _value LIKE 'sql:%'
             AND EXISTS (
                 SELECT 1
                 FROM pg_roles r
                 WHERE r.rolname = SPLIT_PART(_value, ':', 2)
             )
            THEN NULL

        -- Check "application" user pattern is valid
         WHEN _value ~ '^app:\d+$'
            THEN NULL

        ELSE
            FORMAT('Invalid audit user: "%s"', _value)
    END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_audit_user
    IS 'Validation function - check if audit user is (kind of) valid';
