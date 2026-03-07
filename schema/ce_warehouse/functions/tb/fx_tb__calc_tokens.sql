/*
 ***********************************************************************************************************
 * @file
 * fx_tb__calc_tokens.sql
 *
 * Pseudo table function - calculation tokens, @see CEP-440..
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__calc_tokens;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__calc_tokens(
    _calc_table TEXT DEFAULT 'ce_warehouse.c__calc_v2',
    _const_table TEXT DEFAULT 'ce_warehouse.c__const'
)
    RETURNS TABLE (
        tgt_series_id TEXT,
        tokens TEXT[]
    )
    LANGUAGE plpgsql
    STABLE
AS
$$
BEGIN
    RETURN QUERY EXECUTE FORMAT($sql$
        SELECT
            tgt_series_id,
            ARRAY_AGG(DISTINCT token ORDER BY token) AS tokens
        FROM (
            SELECT
                tgt_series_id,
                COALESCE(const.token, calc.token) AS token
            FROM (
                SELECT
                    tgt_series_id,
                    UNNEST(REGEXP_MATCHES(formula, '#([^#]+)#', 'g')) AS token
                FROM %s
                WHERE formula ~ '#([^#]+)#'
            ) calc
            LEFT JOIN (
                SELECT
                    'const:' || con_code AS code,
                    UNNEST(REGEXP_MATCHES(con_expr, '#([^#]+)#', 'g')) AS token
                FROM %s
                WHERE con_expr ~ '#([^#]+)#'
            ) const
            ON calc.token = const.code
            AND const.code IS NOT NULL
        ) t
        GROUP BY 1
        ORDER BY 1
    $sql$, _calc_table, _const_table);
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__calc_tokens
    IS 'Pseudo table function - calculation tokens, @see CEP-440';
