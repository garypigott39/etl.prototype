/*
 ***********************************************************************************************************
 * @file
 * fx_tb_groups.sql
 *
 * Pseudo table function - get geography groups.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_etl.fx_tb_groups;

CREATE OR REPLACE FUNCTION ce_etl.fx_tb_groups(
)
    RETURNS TABLE (
        fk_pk_g INT,
        gp_id TEXT,
        gp_description TEXT,
        error TEXT
    )
    LANGUAGE sql
    STABLE
    PARALLEL SAFE
AS
$$
    SELECT
        g.pk_geo,
        u.gid,
        s.name,
        g.error
    FROM ce_etl.c_geo g
    CROSS JOIN LATERAL UNNEST(g.geo_groups) AS u(gid)
    LEFT JOIN ce_etl.s_geo_group s
        ON u.gid = s.code
    WHERE g.geo_groups IS NOT NULL;
$$;

COMMENT ON FUNCTION ce_etl.fx_tb_groups
    IS 'Pseudo table function - get geo/commodity groups';
