/*
 ***********************************************************************************************************
 * @file
 * px_ut__fix_series_meta.sql
 *
 * Utility procedure - fix missing (& remove dangling) series metadata records, BELT & BRACES!!
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__fix_series_meta;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__fix_series_meta(
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO ce_warehouse.c__series_meta (fk_pk_series, sid1, ifreq, itype)
        SELECT
            s.pk_series,
            s.sid1,
            f.pk_freq,
            t.pk_type
        FROM ce_warehouse.c__series s
			CROSS JOIN ce_warehouse.l__freq f
            CROSS JOIN ce_warehouse.l__type t
        ORDER BY 1, 3, 4
    ON CONFLICT (sid3)
        DO NOTHING;

    -- and remove any dangling metadata records (i.e. those with no matching series record, BELT & BRACES!!)
    DELETE FROM ce_warehouse.c__series_meta m
    WHERE NOT EXISTS (
        SELECT 1
        FROM ce_warehouse.c__series s
        WHERE s.pk_series = m.fk_pk_series
        AND s.sid1 = m.sid1
    );

END
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__fix_series_meta
    IS 'Utility procedure - fix missing (& remove dangling) series metadata records, BELT & BRACES!!';
