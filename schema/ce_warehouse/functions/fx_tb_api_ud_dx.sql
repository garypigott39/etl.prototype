/*
 ***********************************************************************************************************
 * @file
 * fx_tb_api_ud_dx.sql
 *
 * Pseudo table function - provide a list of UD API (DX) calculation data.
 * Output is formulated to match target table structure - note, tooltip & error are always NULL!!
 *
 * @thanks ChatGPT for optimisation suggestions.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb_api_ud_dx;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb_api_ud_dx(
    _phase INT DEFAULT NULL,
    _regen_all BOOLEAN DEFAULT FALSE,
    _include_unchanged BOOLEAN DEFAULT FALSE
)
    RETURNS TABLE (
        uv_gcode      TEXT,
        uv_icode      TEXT,
        uv_period     TEXT,
        uv_freq       TEXT,
        uv_type       TEXT,
        uv_source     TEXT,
        uv_value      TEXT,
        uv_tooltip    TEXT,
        update_type   TEXT,
        pks           INT,
        pdi           INT,
        freq          INT,
        type          INT,
        is_api        BOOLEAN,
        file_name     TEXT,
        error         TEXT,
        regenerate    BOOL
    )
    LANGUAGE plpgsql
AS
$$
DECLARE
    _DATE       DATE := CURRENT_DATE;
    _AC_TYPE    INT := 1;
    _FILENAME   TEXT := 'ce_warehouse.fx_tb_api_ud_dx';

BEGIN
    IF _phase IS NULL THEN
        RAISE EXCEPTION 'Phase parameter is required';
    ELSEIF _phase NOT IN (1, 2) THEN
        RAISE EXCEPTION 'Unsupported phase: %', _phase;
    END IF;

    --------------------------------------------------------------------------------
    -- 1. RULES
    --------------------------------------------------------------------------------
    CREATE TEMP TABLE t__rules ON COMMIT DROP AS
    SELECT
        src.pk_s                AS src_pk_s,
        tgt.pk_s                AS tgt_pk_s,
        calc.ca_source_freq_int AS src_freq,
        tgt_freq                AS tgt_freq,
        tgt.s_gcode             AS tgt_gcode,
        tgt.s_icode             AS tgt_icode,
        calc.ca_formula_type    AS formula,
        calc.regenerate         AS regen
    FROM ce_warehouse.c_api_calc calc
    JOIN ce_warehouse.c_series src
      ON src.s_series_id = calc.ca_source_series
     AND src.s_active
     AND src.error IS NULL
    JOIN ce_warehouse.c_series tgt
      ON tgt.s_series_id = calc.ca_target_series
     AND tgt.s_active
     AND tgt.error IS NULL
    -- Expand target frequencies
    CROSS JOIN LATERAL UNNEST(calc.ca_target_freq_int) AS tgt_freq
    WHERE calc.error IS NULL
    AND (_regen_all OR calc.regenerate)
    AND (
        (_phase = 1 AND calc.ca_formula_type IN ('peop', 'psum', 'pmean')) OR
        (_phase = 2 AND calc.ca_formula_type IN ('growth', 'growth-1'))
    );

    CREATE INDEX t__rules__src_pks__idx
        ON t__rules (src_pk_s, src_freq);

    CREATE INDEX t__rules__tgt_pks__idx
        ON t__rules (tgt_pk_s);

    ANALYZE t__rules;

    --------------------------------------------------------------------------------
    -- 2. CALCULATIONS
    --------------------------------------------------------------------------------
    IF _phase = 1 THEN
        CREATE TEMP TABLE t__calculations ON COMMIT DROP AS
        SELECT
            r.tgt_pk_s        AS fk_pk_s,
            r.tgt_gcode       AS gcode,
            r.tgt_icode       AS icode,
            x.tgt_freq        AS freq,
            x.tgt_pdi         AS pdi,
            x.tgt_period      AS period,
            -- Truncate to 17 decimal places to avoid precision issues
            ce_warehouse.fx_ut_trunc_dps(
                CASE
                    WHEN r.formula = 'peop' THEN x.last_value
                    WHEN r.formula = 'psum' THEN x.sum_value
                    WHEN r.formula = 'pmean' AND x.ct_periods > 0 THEN x.sum_value / x.ct_periods
                END,
                17
            )                 AS value,
            r.regen           AS regen
        FROM ce_warehouse.mv_xvalue x
        JOIN t__rules r
          ON r.src_pk_s = x.fk_pk_s
         AND r.src_freq = x.src_freq
         AND x.tgt_freq = r.tgt_freq
        JOIN ce_warehouse.mv_xperiod p
          ON p.src_pdi  = x.src_pdi
         AND p.src_freq = x.src_freq
         AND p.tgt_freq = x.tgt_freq
         AND (
             (x.src_freq = 3 AND x.tgt_freq = 4 AND x.ct_periods = 3) OR
             (x.src_freq = 3 AND x.tgt_freq = 5 AND x.ct_periods = 12) OR
             (x.src_freq = 4 AND x.tgt_freq = 5 AND x.ct_periods = 4) OR
             (p.tgt_end_of_period < _DATE AND x.src_freq IN (1, 2))
         );
    ELSE
        --------------------------------------------------------------------------------
        -- Generate period lookup table with x & y PDIs as this greatly speeds up the
        -- subsequent JOINs against datapoint values.
        --------------------------------------------------------------------------------
        CREATE TEMP TABLE t__period ON COMMIT DROP AS
        SELECT
            px.p_freq         AS freq,
            px.p_period       AS period,
            px.pk_p           AS x_pdi,
            py.pk_p           AS y_pdi,
            'growth'          AS formula_type
        FROM ce_warehouse.mv_period px
        JOIN ce_warehouse.mv_period py
          ON px.p_freq = py.p_freq
         AND (
              (px.p_freq = 3 AND py.p_lag = (px.p_lag - 12)) OR
              (px.p_freq = 4 AND py.p_lag = (px.p_lag - 4)) OR
              (px.p_freq = 5 AND py.p_lag = (px.p_lag - 1))
             )
        UNION ALL
        SELECT
            px.p_freq         AS freq,
            px.p_period       AS period,
            px.pk_p           AS x_pdi,
            py.pk_p           AS y_pdi,
            'growth-1'        AS formula_type
        FROM ce_warehouse.mv_period px
        JOIN ce_warehouse.mv_period py
          ON px.p_freq = py.p_freq
         AND py.p_lag = (px.p_lag - 1);

        ANALYZE t__period;

        -- Do the work!
        CREATE TEMP TABLE t__calculations ON COMMIT DROP AS
        SELECT
            r.tgt_pk_s        AS fk_pk_s,
            r.tgt_gcode       AS gcode,
            r.tgt_icode       AS icode,
            x.freq            AS freq,
            x.pdi             AS pdi,
            p.period          AS period,
            -- Truncate to 17 decimal places to avoid precision issues
            ce_warehouse.fx_ut_trunc_dps(
                ((x.value - y.value) / y.value) * 100,
                17
            )                 AS value,
            r.regen           AS regen
        FROM ce_warehouse.x_value x
        JOIN ce_warehouse.x_value y
          ON x.fk_pk_s = y.fk_pk_s
         AND x.freq = y.freq
         AND y.value <> 0  -- Prevent division by zero
        JOIN t__rules r
          ON r.src_pk_s = x.fk_pk_s
         AND x.freq = r.tgt_freq
        JOIN t__period p
          ON x.pdi = p.x_pdi
         AND x.freq = p.freq
         AND y.pdi = p.y_pdi
         AND y.freq = p.freq  -- Superfluous, but clearer
         AND r.formula = p.formula_type;
    END IF;

    CREATE INDEX t__calculations__pks_pdi__idx
        ON t__calculations (fk_pk_s, pdi);

    ANALYZE t__calculations;

    --------------------------------------------------------------------------------
    -- 3. UPSERTS
    --------------------------------------------------------------------------------
    CREATE TEMP TABLE t__upserts ON COMMIT DROP AS
    SELECT *
    FROM (
        SELECT
            c.fk_pk_s,
            c.gcode,
            c.icode,
            c.freq,
            c.pdi,
            c.period,
            c.value,
            c.regen,
            CASE
                WHEN x.fk_pk_s IS NULL THEN 'NEW'
                WHEN x.value IS DISTINCT FROM c.value
                    OR x.type IS DISTINCT FROM _AC_TYPE
                    OR x.source IS DISTINCT FROM 'DX' THEN 'UPDATE'
                ELSE 'UNCHANGED'
            END AS update_type
        FROM t__calculations c
        LEFT JOIN ce_warehouse.x_value x
          ON x.fk_pk_s = c.fk_pk_s
         AND x.pdi = c.pdi
    ) s
    WHERE _include_unchanged OR s.update_type <> 'UNCHANGED';

    CREATE INDEX idx_t__upserts__type__idx
        ON t__upserts (update_type);

    ANALYZE t__upserts;

    --------------------------------------------------------------------------------
    -- 4. DELETES
    --------------------------------------------------------------------------------
    CREATE TEMP TABLE t__deletes ON COMMIT DROP AS
    SELECT
        x.fk_pk_s      AS fk_pk_s,
        r.tgt_gcode    AS gcode,
        r.tgt_icode    AS icode,
        x.freq         AS freq,
        x.pdi          AS pdi,
        p.p_period     AS period,
        x.value        AS value,
        r.regen        AS regen,
        'DELETE'       AS update_type
    FROM ce_warehouse.x_value x
    JOIN ce_warehouse.period p
      ON p.pk_p = x.pdi
    JOIN t__rules r
      ON r.tgt_pk_s = x.fk_pk_s
     AND x.freq = r.tgt_freq
    WHERE x.type = _AC_TYPE
      AND NOT EXISTS (
          SELECT 1
          FROM t__calculations c
          WHERE c.fk_pk_s = x.fk_pk_s
            AND c.pdi     = x.pdi
    );

    ANALYZE t__deletes;

    --------------------------------------------------------------------------------
    -- 5. FINAL RESULT
    --------------------------------------------------------------------------------
    RETURN QUERY
    SELECT
        u.gcode        AS uv_gcode,
        u.icode        AS uv_icode,
        u.period       AS uv_period,
        f.code         AS uv_freq,
        'AC'           AS uv_type,
        'DX'           AS uv_source,
        u.value::TEXT  AS uv_value,
        NULL::TEXT     AS uv_tooltip,
        u.update_type  AS update_type,
        u.fk_pk_s      AS pks,
        u.pdi          AS pdi,
        u.freq         AS freq,
        _AC_TYPE       AS type,
        FALSE          AS is_api,
        _FILENAME      AS file_name,
        NULL::TEXT     AS error,
        u.regen
    FROM t__upserts u
    JOIN ce_warehouse.freq f
      ON u.freq = f.pk_f

    UNION ALL

    SELECT
        d.gcode,
        d.icode,
        d.period,
        f.code,
        'AC',
        'DX',
        d.value::TEXT,
        NULL::TEXT,
        d.update_type,
        d.fk_pk_s,
        d.pdi,
        d.freq,
        _AC_TYPE,
        FALSE,
        _FILENAME,
        NULL::TEXT,
        d.regen
    FROM t__deletes d
    JOIN ce_warehouse.freq f
      ON d.freq = f.pk_f;
END;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb_api_ud_dx
  IS 'Pseudo table function - provide a list of UD API (DX) calculation data';
