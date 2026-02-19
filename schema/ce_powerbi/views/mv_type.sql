/*
 ***********************************************************************************************************
 * @file
 * mv_type.sql
 *
 * Materialized View - type lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_type;

CREATE MATERIALIZED VIEW ce_powerbi.mv_type
AS
    SELECT
        pk_t,
        code  AS t_code,
        name  AS t_name
    FROM ce_warehouse.l_type

    UNION ALL

    SELECT
        -1,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text()
    ORDER BY 1;

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_type
    IS 'Materialized View - type lookup';
