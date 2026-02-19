/*
 ***********************************************************************************************************
 * @file
 * mv_fact_series_value.sql
 *
 * Materialized View - "fact" table for series value.
 ***********************************************************************************************************
 */

-- DROP VIEW IF EXISTS ce_powerbi.mv_fact_series_value;

CREATE OR REPLACE VIEW ce_powerbi.mv_fact_series_value
AS
    SELECT
        x.idx            AS pk_sv,
        x.value          AS sv_value,
        a.old_value      AS sv_old_value,
        x.fk_pk_tip      AS fk_pk_tip,
        sx.pk_s          AS fk_pk_s,
        x.pdi            AS fk_pk_p,
        ce_warehouse.fx_ut_date_to_dti(
            CASE s.s_date_point
                WHEN 'start' THEN p.start_of_period
                WHEN 'end' THEN p.end_of_period
                ELSE p.mid_of_period
            END
        )                AS fk_pk_d,
        x.source         AS fk_pk_src,  -- 1:1 mapping
        x.type           AS fk_pk_t,    -- ditto
        x.freq           AS fk_pk_f,    -- ditto
        sx.fk_pk_geo     AS fk_pk_geo,
        sx.fk_pk_com     AS fk_pk_com,
        sx.fk_pk_i       AS fk_pk_i
    FROM ce_warehouse.x_value x
        JOIN ce_warehouse.c_series s
            ON s.pk_s = x.fk_pk_s
            AND s.error IS NULL
        LEFT JOIN ce_warehouse.mv_period p
            ON p.pk_p = x.pdi
            AND p.freq = x.freq
        LEFT JOIN ce_powerbi.mv_sid_xref sx
            ON sx.base_pks = x.fk_pk_s
            AND sx.freq = x.freq
            AND sx.type = x.type
        LEFT JOIN (
            SELECT
                DISTINCT ON(fk_pk_s, pdi)
                fk_pk_s, pdi, value AS old_value
            FROM ce_warehouse.a_x_value
            WHERE audit_type = 'U'
        ) a
            ON a.fk_pk_s = x.fk_pk_s
            AND a.pdi = x.pdi
    WHERE x.error IS NULL;

COMMENT ON VIEW ce_powerbi.fact_series_value
    IS 'View - "fact" table for series value';
