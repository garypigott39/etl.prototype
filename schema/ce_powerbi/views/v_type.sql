/*
 ***********************************************************************************************************
 * @file
 * v_type.sql
 *
 * View - type lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.v_type;

CREATE OR REPLACE VIEW ce_powerbi.v_type
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

COMMENT ON VIEW ce_powerbi.v_type
    IS 'View - type lookup';
