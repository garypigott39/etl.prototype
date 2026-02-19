/*
 ***********************************************************************************************************
 * @file
 * mv_sid_xref.sql
 *
 * Materialized View - series ID metadata/xref lookup.
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_powerbi.mv_sid_xref;

CREATE MATERIALIZED VIEW ce_powerbi.mv_sid_xref
AS
    WITH _base AS (
        SELECT
            pk_s,
            s_gcode                AS gcode,
            s_icode                AS icode,
            s_date_point           AS date_point,
            SUBSTR(s_series_id, 3) AS s3
        FROM ce_warehouse.c_series
        WHERE s_gcode <> 'INTERNAL'
        AND error IS NULL
    ),
    _blended AS (
        SELECT
            fk_pk_s,
            freq,
            CASE
                WHEN BOOL_OR(type = 1) AND BOOL_OR(type = 2) THEN 'BLENDED'
                WHEN BOOL_OR(type = 1) THEN 'AC'
                WHEN BOOL_OR(type = 2) THEN 'F'
            END AS label
        FROM ce_warehouse.x_series_value
        WHERE has_values = TRUE  -- only consider frequencies/types where there are values for the series
        GROUP BY fk_pk_s, freq
    ),
    _min_max_periods AS (
        SELECT
            fk_pk_s,
            freq,
            type,
            MIN(pdi) AS first_pdi,
            MAX(pdi) AS last_pdi
        FROM ce_warehouse.x_value
        WHERE error IS NULL
        GROUP BY fk_pk_s, freq, type
    )
    SELECT
        ((f.pk_f * 10) + t.pk_t) * 100000000) + b.pk_s
                                               AS pk_s,  --derived UNIQUE key!!
        b.pk_s                                 AS base_pks,
        f.pk_f                                 AS freq,
        f.code                                 AS freq_code,
        t.pk_t                                 AS type,
        t.code                                 AS type_code,
        b.s3 || '_' || f.code || '_' || t.code AS s_id_1,
        b.s3 || '_' || f.code                  AS s_id_2,
        b.s3                                   AS s_id_3,
        bl.label                               AS s_id_2_blended,
        COALESCE(sm.sm_downloadable, 'ess_plugin')
                                               AS downloadable,
        xsv.new_values_utc                     AS new_values_utc,
        xsv.updated_values_utc                 AS updated_values_utc,
        xsv.updated_utc                        AS updated_utc,
        -- First & last periods
        first.period_name                      AS first_period,
        last.period_name                       AS last_period,
        -- ADJ dates
        CASE b.date_point
            WHEN 'start' THEN first.start_of_period
            WHEN 'end' THEN first.end_of_period
            ELSE first.mid_of_period
        END                                    AS first_date,
        CASE b.date_point
            WHEN 'start' THEN last.start_of_period
            WHEN 'end' THEN last.end_of_period
            ELSE last.mid_of_period
        END                                    AS last_date,
        -- FOREIGN keys
        g.pk_geo                               AS fk_pk_geo,
        c.pk_com                               AS fk_pk_com,
        i.pk_i                                 AS fk_pk_i
    FROM _base b
        JOIN _blended bl
            ON bl.fk_pk_s = b.pk_s
        JOIN ce_warehouse.l_freq f
            ON f.pk_f = bl.freq
        JOIN ce_warehouse.l_type t
            ON bl.label IN ('BLENDED', t.code)
        JOIN ce_warehouse.x_series_value xsv
            ON xsv.fk_pk_s = b.pk_s
            AND xsv.freq = f.pk_f
            AND xsv.type = t.pk_t
        LEFT JOIN ce_warehouse.c_sid_meta sm
            ON sm.sm_gcode = b.gcode
            AND sm.sm_icode = b.icode
            AND sm.sm_freq = f.code
            AND sm.sm_type = t.code
            AND sm.error IS NULL
        LEFT JOIN _min_max_periods mx
            ON mx.fk_pk_s = b.pk_s
            AND mx.freq = f.pk_f
            AND mx.type = t.pk_t
        LEFT JOIN ce_warehouse.mv_period first
            ON first.pk_p = mx.first_pdi
        LEFT JOIN ce_warehouse.mv_period last
            ON last.pk_p = mx.last_pdi
        LEFT JOIN ce_warehouse.c_geo g
            ON g.geo_code = b.gcode
            AND b.gcode LIKE 'G.%'
        LEFT JOIN ce_warehouse.c_com c
            ON c.com_code = b.gcode
            AND b.gcode LIKE 'C.%'
        LEFT JOIN ce_warehouse.c_ind i
            ON i.i_code = b.icode;

CREATE UNIQUE INDEX IF NOT EXISTS mv_sid_xref__pk_sv__idx
    ON ce_powerbi.mv_sid_xref (pk_sm);

CREATE INDEX IF NOT EXISTS mv_sid_xref__base_pks__idx
    ON ce_powerbi.mv_sid_xref (base_pks);

COMMENT ON MATERIALIZED VIEW ce_powerbi.mv_sid_xref
    IS 'Materialized View - series ID metadata/xref lookup';
