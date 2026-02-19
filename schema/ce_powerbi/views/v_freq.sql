/*
 ***********************************************************************************************************
 * @file
 * v_freq.sql
 *
 * View - frequency lookup.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.v_freq;

CREATE OR REPLACE VIEW ce_powerbi.v_freq
AS
    SELECT
        pk_f,
        code  AS f_code,
        name  AS f_name,
        pk_f  AS f_order  -- ordering column
    FROM ce_warehouse.l_freq

    UNION ALL

    SELECT
        -1,
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_text(),
        ce_powerbi.fx_ut_null_int();

COMMENT ON VIEW ce_powerbi.v_freq
    IS 'View - frequency lookup';
