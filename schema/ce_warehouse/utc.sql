/*
 ***********************************************************************************************************
 * @file
 * utc.sql
 *
 * Set timezone to UTC for all sessions, to ensure consistent handling of timestamps (e.g. ts_updated).
 ***********************************************************************************************************
 */

DO
$$
BEGIN
    EXECUTE FORMAT('ALTER DATABASE %I SET timezone TO ''UTC''', current_database());
END
$$;
