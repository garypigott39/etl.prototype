/*
 ***********************************************************************************************************
 * @file
 * mv_com.sql
 *
 * Materialized View - commodity lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_com;

CREATE MATERIALIZED VIEW ce_powerbi.mv_com
AS
    SELECT
        pk_com,
        com_code,
        ce_powerbi.fx_ut_null_text(com_name)        AS com_name,
        SUBSTR(com_code, 3)                         AS com_short_code,
        ce_powerbi.fx_ut_null_text(com_short_name)  AS com_short_name,
        ce_powerbi.fx_ut_null_text(com_tla)         AS com_tla,
        ce_powerbi.fx_ut_null_text(com_type)        AS com_type,
        ce_powerbi.fx_ut_null_int(com_order)        AS com_order
    FROM ce_warehouse.c_com
    WHERE error IS NULL

    UNION ALL

    SELECT
        -1,
        '_undef',
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_com
    IS 'Materialized View - commodity lookup';
