/*
 ***********************************************************************************************************
 * @file
 * mv_source.sql
 *
 * Materialized View - source lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_source;

CREATE MATERIALIZED VIEW ce_powerbi.mv_source
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
        ce_powerbi.fx_ut_null_bool()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_source
    IS 'Materialized View - source lookup';
