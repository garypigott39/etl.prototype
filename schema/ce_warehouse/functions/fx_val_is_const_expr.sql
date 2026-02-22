/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_const_expr.sql
 *
 * Validation function - check constant expression.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_const_expr;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_const_expr(
    _expr TEXT
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _num   NUMERIC;
    _m     TEXT[];
    _tok   TEXT;
    _pdi1  TEXT;
    _pdi2  TEXT;
BEGIN
    IF _expr IS NULL OR TRIM(p_expr) = '' THEN
        RETURN 'Expression cannot be null or empty';
    END IF;

    ----------------------------------------------------------------
    -- 1️⃣ Numeric (positive or negative, optional decimals)
    ----------------------------------------------------------------
    IF _expr ~ '^[-+]?\d+(\.\d+)?$' THEN
        RETURN NULL;
    END IF;

    ----------------------------------------------------------------
    -- 2️⃣ #TOKEN#,PERIOD
    ----------------------------------------------------------------
    SELECT REGEXP_MATCHES(_expr,
           '^#([^#]+)#,(\d{9})$')
    INTO m;

    IF m IS NOT NULL THEN
        _tok  := m[1];
        _pdi1 := m[2];

        -- Token & Period must exist
        IF NOT EXISTS (SELECT 1 FROM ce_warehouse.c_series s WHERE s.series_id = _tok) THEN
            RETURN FORMAT('Token "%s" does not exist', _tok);
        ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.l_period p WHERE p.pk_pdi = _pdi1::INT) THEN
            RETURN FORMAT('Period "%s" does not exist', _pdi1);
        END IF;

        RETURN NULL;
    END IF;

    ----------------------------------------------------------------
    -- 3️⃣ sd() or mean()
    ----------------------------------------------------------------
    SELECT regexp_matches(_expr,
           '^(sd|mean)\(#([^#]+)#,(\d{9}),(\d{9})\)$')
    INTO m;

    IF m IS NOT NULL THEN
        -- m[1] = function name (sd|mean) – already validated by regex
        _tok  := m[2];
        _pdi1 := m[3];
        _pdi2 := m[4];

        -- Period 1 must be <= Period 2, Token must exist, and both periods must exist
        IF _pdi1 > _pdi2 THEN
            RETURN 'Period 1 must be less than or equal to Period 2';
        ELSEIF _pdi1 ~ '^[1-5]' THEN
            RETURN FORMAT('Period 1 %s is invalid, must start with 1-5', _pdi1);
        ELSEIF _pdi2 ~ '^[1-5]' THEN
            RETURN FORMAT('Period 2 %s is invalid, must start with 1-5', _pdi1);
        ELSEIF LEFT(_pdi1, 1) <> LEFT(_pdi2,  1) THEN
            RETURN 'Period 1 and Period 2 must be in the same frequency group';
        ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.c_series s WHERE s.series_id = _tok) THEN
            RETURN FORMAT('Token "%s" does not exist', _tok);
        ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.l_period p WHERE p.pk_pdi = _pdi1::INT) THEN
            RETURN FORMAT('Period "%s" does not exist', _pdi1);
        ELSEIF NOT EXISTS (SELECT 1 FROM ce_warehouse.l_period p WHERE p.pk_pd2 = _pdi2::INT) THEN
            RETURN FORMAT('Period "%s" does not exist', _pdi2);
        END IF;

        RETURN NULL;
    END IF;

    ----------------------------------------------------------------
    -- Anything else → invalid
    ----------------------------------------------------------------
    RETURN 'Invalid expression format';

    EXCEPTION WHEN others THEN
        RETURN FORMAT('Unable to parse expression %s', _expr);  -- catch any unexpected errors and treat as invalid
END;
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_const_expr
    IS 'Validation function - check constant expression';
