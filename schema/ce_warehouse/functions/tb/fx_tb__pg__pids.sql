/*
 ***********************************************************************************************************
 * @file
 * fx_tb__pg__pids.sql
 *
 * Pseudo/Postgres table function - get list of PostgreSQL processes.

 * Note, to clear them you can run:
 *
 *      `SELECT pg_terminate_backend(pid)
 *        FROM pg_stat_activity
 *        WHERE datname = CURRENT_DATABASE()
 *        AND pid <> pg_backend_pid();`
 *
 * But be careful, this will kill all connections to the database except the one running the query, so use with caution!!!
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__pg__pids;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__pg__pids(
)
    RETURNS TABLE (
        pid INT,
        state TEXT,
        query TEXT,
        backend_pid TEXT
    )
    LANGUAGE sql
AS
$$
    SELECT
        pid,
        state,
        query,
        CASE pid
            WHEN pg_backend_pid() THEN '[[ Current ]]'
            ELSE 'Other'
        END AS backend_process
    FROM pg_stat_activity
    WHERE datname = CURRENT_DATABASE()
    ORDER BY 1;
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__pg__pids
    IS 'Pseudo/Postgres table function - get list of PostgreSQL processes';
