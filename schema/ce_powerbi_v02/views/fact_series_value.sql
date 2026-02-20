/*
 ***********************************************************************************************************
 * @file
 * fact_series_value.sql
 *
 * View - "fact" table for series value.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi_v02.fact_series_value;

CREATE OR REPLACE VIEW ce_powerbi_v02.fact_series_value
AS
    -- As per base materialized view (without sv_updated_utc)
    SELECT
        pk_sv,
        sv_value,
        sv_old_value,
        fk_pk_tip,
        fk_pk_s,
        fk_pk_p,
        fk_pk_d,
        fk_pk_src,
        fk_pk_t,
        fk_pk_f,
        fk_pk_geo,
        fk_pk_com,
        fk_pk_i
    FROM ce_powerbi.mv_fact_series_value;

COMMENT ON VIEW ce_powerbi_v02.fact_series_value
    IS 'View - "fact" table for series value';
