DO
$$
DECLARE
    v_conn TEXT := 'dbname=testdb user=postgres password=postgres host=localhost';
BEGIN

    -- Ensure dblink exists
    PERFORM 1 FROM pg_extension WHERE extname = 'dblink';
    IF NOT FOUND THEN
        EXECUTE 'CREATE EXTENSION dblink';
    END IF;

    -- Open connection
    PERFORM dblink_connect('myconn', v_conn);

    ------------------------------------------------------------------
    -- OPTIONAL: truncate first (remove if not desired)
    ------------------------------------------------------------------
    TRUNCATE TABLE
        ce_etl.c_api_calc,
        ce_etl.c_calc,
        ce_etl.c_com,
        ce_etl.c_const,
        ce_etl.c_geo,
        ce_etl.c_ind,
        ce_etl.c_series_meta,
        ce_etl.c_series
    RESTART IDENTITY CASCADE;

    ------------------------------------------------------------------
    -- COPY TABLES with named columns
    ------------------------------------------------------------------

    -- c_api_calc
    EXECUTE $q$
        INSERT INTO ce_etl.c_api_calc (
            ca_target_series,
            ca_target_freq,
--             ca_target_freq_int,
            ca_source_series,
            ca_source_freq,
--             ca_source_freq_int,
            ca_formula_type,
            internal_notes,
            error,
            regenerate,
            updated_utc,
            pk_api_calc
        ) OVERRIDING SYSTEM VALUE
        SELECT
            ca_target_series,
            ca_target_freq,
--             ca_target_freq_int,
            ca_source_series,
            ca_source_freq,
--             ca_source_freq_int,
            ca_formula_type,
            internal_notes,
            error,
            regenerate,
            updated_utc,
            pk_api_calc
        FROM dblink('myconn','SELECT * FROM ce_data.c_api_calc')
        AS t(
            ca_target_series TEXT,
            ca_target_freq TEXT[],
--             ca_target_freq_int INT[],
            ca_source_series TEXT,
            ca_source_freq TEXT,
--             ca_source_freq_int INT,
            ca_formula_type TEXT,
            internal_notes TEXT,
            error TEXT,
            regenerate BOOLEAN,
            updated_utc TIMESTAMP,
            pk_api_calc INT
        )
    $q$;

    -- c_calc
    EXECUTE $q$
        INSERT INTO ce_etl.c_calc (
            calc_series,
            calc_freq,
            calc_type,
            calc_formula,
            internal_notes,
            error,
            updated_utc,
            pk_calc
        ) OVERRIDING SYSTEM VALUE
        SELECT
            calc_series,
            calc_freq,
            calc_type,
            calc_formula,
            internal_notes,
            error,
            updated_utc,
            pk_calc
        FROM dblink('myconn','SELECT * FROM ce_data.c_calc')
        AS t(
            calc_series TEXT,
            calc_freq TEXT,
            calc_type TEXT,
            calc_formula TEXT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_calc INT
        )
    $q$;

    -- c_com
    EXECUTE $q$
        INSERT INTO ce_etl.c_com (
            com_code,
            com_name,
            com_short_name,
            com_tla,
            com_type,
            com_order,
            internal_notes,
            error,
            updated_utc,
            pk_com
        ) OVERRIDING SYSTEM VALUE
        SELECT
            com_code,
            com_name,
            com_short_name,
            com_tla,
            com_type,
            com_order,
            internal_notes,
            error,
            updated_utc,
            pk_com
        FROM dblink('myconn','SELECT * FROM ce_data.c_com')
        AS t(
            com_code TEXT,
            com_name TEXT,
            com_short_name TEXT,
            com_tla TEXT,
            com_type TEXT,
            com_order INT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_com INT
        )
    $q$;

    -- c_const
    EXECUTE $q$
        INSERT INTO ce_etl.c_const (
            con_code,
            con_expr,
            value,
            internal_notes,
            error,
            updated_utc,
            pk_con
        ) OVERRIDING SYSTEM VALUE
        SELECT
            con_code,
            con_expr,
            value,
            internal_notes,
            error,
            updated_utc,
            pk_con
        FROM dblink('myconn','SELECT * FROM ce_data.c_const')
        AS t(
            con_code TEXT,
            con_expr TEXT,
            value NUMERIC,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_con INT
        )
    $q$;

    -- c_geo
    EXECUTE $q$
        INSERT INTO ce_etl.c_geo (
            geo_code,
            geo_name,
            geo_name2,
            geo_short_name,
            geo_tla,
            geo_iso2,
            geo_iso3,
            geo_lat,
            geo_long,
            geo_cb,
            geo_cb_short,
            geo_stockmarket,
            geo_stockmarket_short,
            geo_political_alignment,
            geo_lc,
            geo_lcu,
            geo_flag,
            geo_catg,
            geo_groups,
            geo_order,
            internal_notes,
            error,
            updated_utc,
            pk_geo
        ) OVERRIDING SYSTEM VALUE
        SELECT
            geo_code,
            geo_name,
            geo_name2,
            geo_short_name,
            geo_tla,
            geo_iso2,
            geo_iso3,
            geo_lat,
            geo_long,
            geo_cb,
            geo_cb_short,
            geo_stockmarket,
            geo_stockmarket_short,
            geo_political_alignment,
            geo_lc,
            geo_lcu,
            geo_flag,
            geo_catg,
            geo_groups,
            geo_order,
            internal_notes,
            error,
            updated_utc,
            pk_geo
        FROM dblink('myconn','SELECT * FROM ce_data.c_geo')
        AS t(
            geo_code TEXT,
            geo_name TEXT,
            geo_name2 TEXT,
            geo_short_name TEXT,
            geo_tla TEXT,
            geo_iso2 TEXT,
            geo_iso3 TEXT,
            geo_lat NUMERIC,
            geo_long NUMERIC,
            geo_cb TEXT,
            geo_cb_short TEXT,
            geo_stockmarket TEXT,
            geo_stockmarket_short TEXT,
            geo_political_alignment TEXT,
            geo_lc TEXT,
            geo_lcu TEXT,
            geo_flag TEXT,
            geo_catg TEXT,
            geo_groups TEXT[],
            geo_order INT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_geo INT
        )
    $q$;

    -- c_ind
    EXECUTE $q$
        INSERT INTO ce_etl.c_ind (
            i_code,
            i_name,
            i_description,
            i_name1,
            i_name2,
            i_name3,
            i_name4,
            i_name_lower,
            i_name1_lower,
            i_name2_lower,
            i_name3_lower,
            i_name4_lower,
            i_catg_broad,
            i_catg_narrow,
            i_parent_icodes,
            i_data_transformation,
            i_keyindicator,
            i_proprietary_data,
            i_order,
            internal_notes,
            error,
            updated_utc,
            pk_i
        ) OVERRIDING SYSTEM VALUE
        SELECT
            i_code,
            i_name,
            i_description,
            i_name1,
            i_name2,
            i_name3,
            i_name4,
            i_name_lower,
            i_name1_lower,
            i_name2_lower,
            i_name3_lower,
            i_name4_lower,
            i_catg_broad,
            i_catg_narrow,
            i_parent_icodes,
            i_data_transformation,
            i_keyindicator,
            i_proprietary_data,
            i_order,
            internal_notes,
            error,
            updated_utc,
            pk_i
        FROM dblink('myconn','SELECT * FROM ce_data.c_ind')
        AS t(
            i_code TEXT,
            i_name TEXT,
            i_description TEXT,
            i_name1 TEXT,
            i_name2 TEXT,
            i_name3 TEXT,
            i_name4 TEXT,
            i_name_lower TEXT,
            i_name1_lower TEXT,
            i_name2_lower TEXT,
            i_name3_lower TEXT,
            i_name4_lower TEXT,
            i_catg_broad TEXT,
            i_catg_narrow TEXT,
            i_parent_icodes TEXT[],
            i_data_transformation TEXT,
            i_keyindicator BOOL,
            i_proprietary_data BOOL,
            i_order INT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_i INT
        )
    $q$;

    -- c_series_meta
    EXECUTE $q$
        INSERT INTO ce_etl.c_series_meta (
            sm_gcode,
            sm_icode,
            sm_freq,
            sm_type,
            sm_downloadable,
            forecast_only_lifespan,
            internal_notes,
            error,
            updated_utc,
            pk_sm
        ) OVERRIDING SYSTEM VALUE
        SELECT
            sm_gcode,
            sm_icode,
            sm_freq,
            sm_type,
            sm_downloadable,
            forecast_only_lifespan,
            internal_notes,
            error,
            updated_utc,
            pk_sm
        FROM dblink('myconn','SELECT * FROM ce_data.c_series_metadata')
        AS t(
            sm_gcode TEXT,
            sm_icode TEXT,
            sm_freq TEXT,
            sm_type TEXT,
            sm_downloadable TEXT,
            forecast_only_lifespan INT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_sm INT
        )
    $q$;

    -- c_series
    EXECUTE $q$
        INSERT INTO ce_etl.c_series (
            s_gcode,
            s_icode,
            s_series_id,
            s_name,
            s_name1,
            s_name2,
            s_name3,
            s_name4,
            s_description,
            s_source,
            s_units,
            s_precision,
            s_date_point,
            s_active,
            s_order,
            internal_notes,
            error,
            updated_utc,
            pk_s
        ) OVERRIDING SYSTEM VALUE
        SELECT
            s_gcode,
            s_icode,
            s_series_id,
            s_name,
            s_name1,
            s_name2,
            s_name3,
            s_name4,
            s_description,
            s_source,
            s_units,
            s_precision,
            s_date_point,
            s_active,
            s_order,
            internal_notes,
            error,
            updated_utc,
            pk_s
        FROM dblink('myconn','SELECT * FROM ce_data.c_series')
        AS t(
            s_gcode TEXT,
            s_icode TEXT,
            s_series_id TEXT,
            s_name TEXT,
            s_name1 TEXT,
            s_name2 TEXT,
            s_name3 TEXT,
            s_name4 TEXT,
            s_description TEXT,
            s_source TEXT,
            s_units TEXT,
            s_precision INT,
            s_date_point TEXT,
            s_active BOOL,
            s_order INT,
            internal_notes TEXT,
            error TEXT,
            updated_utc TIMESTAMP,
            pk_s INT
        )
    $q$;

    ------------------------------------------------------------------
    -- Reset sequences safely
    ------------------------------------------------------------------
    CALL ce_etl.px_ut_fix_seq();

    -- Close connection
    PERFORM dblink_disconnect('myconn');

END
$$;
