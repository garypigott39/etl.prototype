/*
 ***********************************************************************************************************
 * @file
 * fx_ut__geo_groups_to_int.sql
 *
 * Pseudo table function - convert group codes array to int.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tb__geo_groups_to_int;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tb__geo_groups_to_int(
    _groups TEXT[]
)
    RETURNS TABLE (
        lk_pk_geo_group SMALLINT
    )
    LANGUAGE sql
    IMMUTABLE
    STRICT
AS
$$
    SELECT l.pk_geo_group
    FROM ce_warehouse.l__geo_group l
        JOIN LATERAL UNNEST(_groups) raw(code)
            ON raw.code = l.code
    GROUP BY 1
    ORDER BY 1
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tb__geo_groups_to_int
    IS 'Pseudo table function - convert group codes array to int';
