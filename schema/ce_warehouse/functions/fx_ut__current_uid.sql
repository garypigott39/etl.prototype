/*
 ***********************************************************************************************************
 * @file
 * fx_ut_session_uid.sql
 *
 * Utility function - get current UID for auditing purposes.
 *
 * NOTE, relies on the app setting 'app.current_uid' being set in the session by the application. If not set,
 * will fall back to the SQL username, and if that is not available, will return 'unknown'.
 *
 * Expected that app will do `SET app.current_uid = <user_id>` at the start of each session, where <user_id>
 * is the unique identifier for the user in the application (e.g. Django user ID).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_session_uid;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_session_uid(
)
    RETURNS TEXT
    LANGUAGE sql
    STABLE
AS
$$
    SELECT
        COALESCE(
            NULLIF('app:' || TRIM(CURRENT_SETTING('app.current_uid', TRUE))::TEXT, 'app:'),
            'sql:' || CURRENT_USER,
            'unknown'
        );
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_session_uid
    IS 'Utility function - get current UID for auditing purposes';
