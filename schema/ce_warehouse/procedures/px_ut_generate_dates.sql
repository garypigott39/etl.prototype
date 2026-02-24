/*
 ***********************************************************************************************************
 * @file
 * px_ut_generate_dates.sql
 *
 * Utility procedure - generate missing dates & periods.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut_generate_dates;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut_generate_dates(
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    _dt DATE;
    _dt1 DATE := (SELECT value::DATE FROM ce_warehouse.s_sys_flags WHERE code = 'DATE.MIN');
    _dt2 DATE := (SELECT (CURRENT_DATE + (value::INTERVAL))::DATE FROM ce_warehouse.s_sys_flags WHERE code = 'DATE.MAX');
BEGIN
    -- 1. DATES
    IF _dt1 IS NULL OR _dt2 IS NULL THEN
        RAISE EXCEPTION 'System flags DATE.MIN and DATE.MAX must be set to generate dates & periods';
    ELSEIF _dt1 > _dt2 THEN
        RAISE EXCEPTION 'System flag DATE.MIN must be less than or equal to DATE.MAX';
    END IF;

    FOR _dt IN
        SELECT gs.date
        FROM generate_series(_dt1, _dt2, INTERVAL '1 DAY') AS gs(date)
            LEFT JOIN ce_warehouse.l_date d
                ON d.date = gs.date
        WHERE d.date IS NULL
    LOOP
        INSERT INTO ce_warehouse.l_date (date)
            VALUES (_dt)
        ON CONFLICT (date) DO NOTHING;
    END LOOP;

    -- 2. PERIODS
    INSERT INTO ce_warehouse.l_period (ifreq, start_of_period, end_of_period, period, lag)
        WITH _periods AS (
            SELECT 1 AS ifreq, d.date AS start_of_period, d.date AS end_of_period
            FROM ce_warehouse.v_date d
            UNION ALL
            SELECT 2, d.start_of_week, d.end_of_week
            FROM ce_warehouse.v_date d
            GROUP BY 2, 3
            UNION ALL
            SELECT 3, d.start_of_month, d.end_of_month
            FROM ce_warehouse.v_date d
            GROUP BY 2, 3
            UNION ALL
            SELECT 4, d.start_of_quarter, d.end_of_quarter
            FROM ce_warehouse.v_date d
            GROUP BY 2, 3
            UNION  ALL
            SELECT 5, d.start_of_year, d.end_of_year
            FROM ce_warehouse.v_date d
            GROUP BY 2, 3
        ),
        _with_lag AS (
            SELECT
                ifreq,
                start_of_period,
                end_of_period,
                CASE ifreq
                    WHEN 1 THEN TO_CHAR(start_of_period, 'YYYY-MM-DD')
                    WHEN 2 THEN TO_CHAR(start_of_period, 'IYYY-"W"IW')
                    WHEN 3 THEN TO_CHAR(start_of_period, 'YYYY-MM')
                    WHEN 4 THEN TO_CHAR(start_of_period, 'YYYY-"Q"Q')
                    ELSE TO_CHAR(start_of_period, 'YYYY')
                END::TEXT  AS period,
                ROW_NUMBER() OVER (PARTITION BY ifreq ORDER BY start_of_period)  AS lag
            FROM _periods
        )
        SELECT
            l.*
        FROM _with_lag l
            LEFT JOIN ce_warehouse.l_period p
                ON p.ifreq = l.ifreq
                AND p.start_of_period = l.start_of_period
        WHERE p.pk_pdi IS NULL;

    -- 3. Refresh materialized views
    REFRESH MATERIALIZED VIEW ce_warehouse.mv_period;
    REFRESH MATERIALIZED VIEW ce_warehouse.mv_xperiod;

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut_generate_dates
    IS 'Utility procedure - generate missing dates & periods';
