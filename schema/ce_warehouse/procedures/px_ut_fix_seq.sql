/*
 ***********************************************************************************************************
 * @file
 * px_ut_fix_seq.sql
 *
 * Utility procedure - fix table sequence(s).
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut_fix_seq;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut_fix_seq(
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    _sql TEXT;

BEGIN
    FOR _sql IN SELECT fix FROM ce_warehouse.fx_tb_seq_check() WHERE fix IS NOT NULL
    LOOP
        CALL ce_warehouse.px_ut_info('Running - ' || _sql);
        EXECUTE _sql;
    END LOOP;
END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut_fix_seq
    IS 'Utility procedure - fix table sequence(s)';
