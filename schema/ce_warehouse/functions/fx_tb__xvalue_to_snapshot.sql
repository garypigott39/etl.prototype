/*
 ***********************************************************************************************************
 * @file
 * fx_tb__xvalue_to_snapshot.sql
 *
 * Pseudo table function - snapshot rows built from specified xvalue row(s).
 ***********************************************************************************************************
 */

--DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__xvalue_to_snapshot;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__xvalue_to_snapshot(
    _pks INT DEFAULT NULL,
    _src_ifreq INT DEFAULT NULL
)
    RETURNS TABLE (
       src_ifreq SMALLINT,
       tgt_ifreq SMALLINT,
       fk_pk_series INT,
       lk_pk_pdi INT,
       ifreq SMALLINT,
       last_pdi INT,
       last_value NUMERIC,
       sum_value NUMERIC,
       num_periods INT
    )
    LANGUAGE plpgsql
AS
$$
DECLARE
    _sql TEXT;
    _where TEXT;
BEGIN
    IF _pks IS NOT NULL THEN
        _where := FORMAT('WHERE v.fk_pk_series = %s', _pks);
    ELSE
        _where := 'WHERE 1=1';
    END IF;

    IF _src_ifreq IS NOT NULL THEN
        _where := _where || FORMAT(' AND v.ifreq = %s', _src_ifreq);
    END IF;

    _sql := FORMAT($sql$
        WITH _latest AS (
            SELECT DISTINCT ON (
                1, 2, 3, 4, 5
            )
                v.ifreq          AS src_ifreq,
                xp.tgt_ifreq     AS tgt_ifreq,
                v.fk_pk_series   AS fk_pk_series,
                xp.tgt_pdi       AS lk_pk_pdi,
                v.itype          AS itype,
                v.lk_pk_pdi      AS last_pdi,
                v.value          AS last_value
            FROM ce_warehouse.x__value v
                JOIN ce_warehouse.mv__xperiod xp
                    ON xp.src_ifreq = v.ifreq
                    AND xp.src_pdi_range @> v.lk_pk_pdi
            %s
            ORDER BY
                1, 2, 3, 4, 5, v.lk_pk_pdi DESC
        ),
        _aggregated AS (
            SELECT
                v.ifreq         AS src_ifreq,
                xp.tgt_ifreq    AS tgt_ifreq,
                v.fk_pk_series  AS fk_pk_series,
                xp.tgt_pdi      AS lk_pk_pdi,
                v.itype         AS itype,
                SUM(v.value)    AS sum_value,
                COUNT(DISTINCT v.lk_pk_pdi)
                                AS num_periods
            FROM ce_warehouse.x__value v
                JOIN ce_warehouse.mv__xperiod xp
                    ON xp.src_ifreq = v.ifreq
                    AND xp.src_pdi_range @> v.lk_pk_pdi
            %s
            GROUP BY
                1, 2, 3, 4, 5
        )
        SELECT
            a.src_ifreq::SMALLINT,
            a.tgt_ifreq::SMALLINT,  -- redundant but useful
            a.fk_pk_series::INT,
            a.lk_pk_pdi::INT,
            a.itype::SMALLINT,
            l.last_pdi::INT,
            l.last_value::NUMERIC,
            a.sum_value::NUMERIC,
            a.num_periods::INT
        FROM _aggregated a
            LEFT JOIN _latest l
                USING (src_ifreq, tgt_ifreq, fk_pk_series, lk_pk_pdi, itype)
    $sql$, _where, _where);

    RETURN QUERY EXECUTE _sql;

END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__xvalue_to_snapshot
    IS 'Pseudo table function - snapshot rows built from specified xvalue row(s)';
