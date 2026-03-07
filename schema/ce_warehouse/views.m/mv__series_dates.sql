/*
 ***********************************************************************************************************
 * @file
 * mv__series_last_upated.sql
 *
 * Materialized View - series last update/insert dates & PDI range.
 * REFRESH periodically (i.e. when no designated by value updates or Pipeline run etc).
 ***********************************************************************************************************
 */

-- DROP MATERIALIZED VIEW IF EXISTS ce_warehouse.mv__series_dates

CREATE MATERIALIZED VIEW IF NOT EXISTS ce_warehouse.mv__series_dates
AS
    WITH _ins AS (
        SELECT
            fk_pk_series,
            ifreq,
            itype,
            MAX(ts_audit_time)  AS ts_last_insert
        FROM ce_warehouse.a__xvalue
        WHERE audit_type = 'I'
        GROUP BY
            fk_pk_series, ifreq, itype
    )
    SELECT
        v.fk_pk_series,
        v.ifreq,
        v.itype,
        MIN(v.lk_pk_pdi)    AS first_pdi,
        MAX(v.lk_pk_pdi)    AS last_pdi,
        MAX(v.ts_updated)   AS ts_last_update,
        i.ts_last_insert    AS ts_last_insert
    FROM ce_warehouse.x__value v
        LEFT JOIN _ins i
            ON v.fk_pk_series = i.fk_pk_series
            AND v.ifreq = i.ifreq
            AND v.itype = i.itype
    GROUP BY
        v.fk_pk_series, v.ifreq, v.itype, i.ts_last_insert;

CREATE UNIQUE INDEX mv__series_dates__series__idx
    ON ce_warehouse.mv__series_dates(fk_pk_series, ifreq, itype);

COMMENT ON MATERIALIZED VIEW ce_warehouse.mv__series_dates
    IS 'Materialized View - series last update/insert dates & PDI range';
