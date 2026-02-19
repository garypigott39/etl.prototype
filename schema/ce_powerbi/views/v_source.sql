/*
 ***********************************************************************************************************
 * @file
 * v_source.sql
 *
 * View - source lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.v_source;

CREATE OR REPLACE VIEW ce_powerbi.v_source
AS
    SELECT
        pk_src,
        code  AS src_code,
        name  AS src_name,
        api_available AS src_api_available
    FROM ce_warehouse.l_source

    UNION ALL

    SELECT
        -1,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_bool();

COMMENT ON VIEW ce_powerbi.v_source
    IS 'View - source lookup';
