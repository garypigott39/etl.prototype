/*
 ***********************************************************************************************************
 * @file
 * fx_tb_calc_tokens.sql
 *
 * Pseudo table function - calculation tokens, @see CEP-440..
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb_calc_tokens;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb_calc_tokens(
    _calc_table TEXT DEFAULT 'ce_warehouse.c_calc',
    _const_table TEXT DEFAULT 'ce_warehouse.c_const'
)
    RETURNS TABLE (
        series TEXT,
        tokens TEXT[]
    )
    LANGUAGE plpgsql
    STABLE
AS
$$
BEGIN
    RETURN QUERY EXECUTE FORMAT($sql$
        SELECT
            calc_series,
            ARRAY_AGG(DISTINCT token ORDER BY token) AS tokens
        FROM (
            SELECT
                calc_series,
                COALESCE(const.token, calc.token) AS token
            FROM (
                SELECT
                    calc_series,
                    UNNEST(REGEXP_MATCHES(calc_formula, '#([^#]+)#', 'g')) AS token
                FROM %s
                WHERE calc_formula ~ '#([^#]+)#'
            ) calc
            LEFT JOIN (
                SELECT
                    'const:' || con_code AS code,
                    UNNEST(REGEXP_MATCHES(con_expr, '#([^#]+)#', 'g')) AS token
                FROM %s
                WHERE con_expr ~ '#([^#]+)#'
            ) const
            ON calc.token = const.code
        ) t
        GROUP BY 1
        ORDER BY 1
    $sql$, _calc_table, _const_table);
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb_calc_tokens
    IS 'Pseudo table function - calculation tokens, @see CEP-440';
