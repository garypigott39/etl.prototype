/*
 ***********************************************************************************************************
 * @file
 * px_ut_info.sql
 *
 * Utility procedure - display function/process info message.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut_info;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut_info(
    _msg TEXT,
    _include_time BOOL DEFAULT FALSE
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _include_time THEN
        _msg := _msg || '  (@ ' || ce_warehouse.fx_ut_utc() || ')';
    END IF;
    RAISE INFO '# %', _msg;
END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut_info
    IS 'Utility procedure - debug/info, display message';