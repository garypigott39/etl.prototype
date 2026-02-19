/*
 ***********************************************************************************************************
 * @file
 * mv_tooltip.sql
 *
 * Materialized View - tooltip lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_tooltip;

CREATE MATERIALIZED VIEW ce_powerbi.mv_tooltip
AS
    SELECT
        pk_tip,
        tooltip AS t_tip
    FROM ce_warehouse.x_tooltip

    UNION ALL

    SELECT
        -1,
        ce_powerbi.fx_ut_null_text();

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_tooltip
    IS 'View - tooltip lookup';
