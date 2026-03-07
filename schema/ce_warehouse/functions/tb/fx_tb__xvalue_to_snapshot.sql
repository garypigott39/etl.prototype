/*
 ***********************************************************************************************************
 * @file
 * fx_tb__xvalue_to_snapshot.sql
 *
 * Pseudo table function - snapshot rows built from specified xvalue row(s).
 ***********************************************************************************************************
 */

DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__xvalue_to_snapshot;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__xvalue_to_snapshot(
    _pks        INT DEFAULT NULL,
    _src_ifreq  INT DEFAULT NULL,
    _src_pdi    INT DEFAULT NULL,
    _debug      BOOL DEFAULT FALSE
)
    RETURNS TABLE (
       src_ifreq        SMALLINT,
       tgt_ifreq        SMALLINT,
       fk_pk_series     INT,
       lk_pk_pdi        INT,
       itype            SMALLINT,
       last_pdi         INT,
       last_value       NUMERIC,
       sum_value        NUMERIC,
       num_periods      INT
    )
    LANGUAGE plpgsql
AS
$$
DECLARE
    _sql TEXT;
    _w1 TEXT;

BEGIN
    IF _src_pdi IS NOT NULL AND _src_pdi < 0 THEN
        RAISE EXCEPTION 'Invalid Source PDI: %', _src_pdi;
    END IF;

    -- This query bit is ONLY optimal when PKS & SRC IFREQ are specified & IFREQ > 1
    IF _pks IS NOT NULL AND _src_pdi IS NOT NULL THEN
        IF _src_ifreq IS NULL THEN
            _src_ifreq := _src_pdi / 100000000;
        ELSEIF _src_ifreq != _src_pdi / 100000000 THEN
            RAISE EXCEPTION 'Source PDI % is not compatible with Source iFreq %', _src_pdi, _src_ifreq;
        END IF;

        _sql := FORMAT($sql$
            WITH _periods AS (
                SELECT
                    xp.tgt_ifreq,
                    xp.tgt_pdi,
                    xp.src_pdi_range
                FROM ce_warehouse.mv__xperiod  xp
                WHERE xp.src_ifreq = %1$s
                AND xp.tgt_ifreq > %1$s
                AND xp.src_pdi_range @> %2$s
            )
            SELECT
                %1$s::SMALLINT              AS src_ifreq,
                p.tgt_ifreq::SMALLINT       AS tgt_ifreq,
                %3$s::INT                   AS fk_pk_series,
                p.tgt_pdi                   AS lk_pk_pdi,
                ag.itype                    AS itype,
                ag.last_pdi                 AS last_pdi,
                ag.last_value               AS last_value,
                ag.sum_value                AS sum_value,
                ag.num_periods::INT         AS num_periods
            FROM _periods p
                JOIN LATERAL (
                    SELECT
                        v.itype             AS itype,
                        MAX(v.lk_pk_pdi)    AS last_pdi,
                        (ARRAY_AGG(v.value ORDER BY v.lk_pk_pdi DESC))[1]
                                            AS last_value,
                        SUM(v.value)        AS sum_value,
                        COUNT(DISTINCT v.lk_pk_pdi)
                                            AS num_periods
                    FROM ce_warehouse.x__value v
                    WHERE v.fk_pk_series = %3$s
                    AND v.ifreq = %1$s
                    AND v.lk_pk_pdi <@ p.src_pdi_range
                    GROUP BY 1
                ) ag ON TRUE
        $sql$, _src_ifreq, _src_pdi, _pks);

    ELSE
        -- This is the more general query which is optimal in other cases
        IF _src_ifreq IS NOT NULL THEN
            _w1 := FORMAT('WHERE v.ifreq = %s', _src_ifreq);
        ELSE
            _w1 := 'WHERE v.ifreq = 1';  -- default to Daily (1) if not specified!!
        END IF;

        IF _pks IS NOT NULL THEN
            _w1 := _w1 || FORMAT(' AND v.fk_pk_series = %s', _pks);
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
                %1$s
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
                %1$s
                GROUP BY
                    1, 2, 3, 4, 5
            )
            SELECT
                ag.src_ifreq,
                ag.tgt_ifreq,  -- redundant but useful
                ag.fk_pk_series,
                ag.lk_pk_pdi,
                ag.itype,
                l.last_pdi,
                l.last_value,
                ag.sum_value,
                ag.num_periods::INT
            FROM _aggregated ag
                LEFT JOIN _latest l
                    USING (src_ifreq, tgt_ifreq, fk_pk_series, lk_pk_pdi, itype)
        $sql$, _w1);
    END IF;

    IF _debug THEN
        RAISE EXCEPTION 'SQL: %', _sql;
    END IF;

    RETURN QUERY EXECUTE _sql;

END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__xvalue_to_snapshot
    IS 'Pseudo table function - snapshot rows built from specified xvalue row(s)';
