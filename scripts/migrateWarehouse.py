#!/usr/bin/env python3
"""
migrateWarehouse.py

This is not suitable for production use, 1-off script to populate local ce_warehouse from old "testdb".

Cobbled together quickly from a now defunct dblink script + some help from ChatGPT.
"""

import io
import os
import platform
import psycopg2

SOURCE_CONN = {
    "dbname": "testdb",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
}

TARGET_CONN = {
    "dbname": "prototype",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
}


# -------------------------------------------------------
# Generic COPY helpers
# -------------------------------------------------------

def copy_table(src_cur, tgt_cur, source_query, target_table):
    """
    Stream data from source query directly into target table using COPY.
    """
    buffer = io.StringIO()

    print(f"Copying -> {target_table}")

    # Export from source
    src_cur.copy_expert(
        f"COPY ({source_query}) TO STDOUT WITH CSV",
        buffer
    )

    buffer.seek(0)

    # Import into target
    tgt_cur.copy_expert(
        f"COPY {target_table} FROM STDIN WITH CSV",
        buffer
    )

    print(f"Finished {target_table}")


def create_temp_from_source(src_cur, tgt_cur, source_query, temp_name):
    """
    Creates a temp table on target using the structure of source query.
    """
    print(f"Creating temp table {temp_name} from source structure...")

    # Get column structure without data
    src_cur.execute(f"SELECT * FROM ({source_query}) AS q LIMIT 0")
    colnames = [desc[0] for desc in src_cur.description]

    # Build CREATE TABLE statement dynamically
    columns_sql = ", ".join(
        f"{col} TEXT" for col in colnames
    )

    # You can improve this to infer types properly (see note below)

    tgt_cur.execute(f"""
        CREATE TEMP TABLE {temp_name} (
            {columns_sql}
        ) ON COMMIT DROP
    """)

    return colnames


# -------------------------------------------------------
# Setup/validation functions
# -------------------------------------------------------

def setup_and_check(src_cur, tgt_cur):
    # Ensure we have no datapoint values
    print("Checking for existing datapoint/values...")
    tgt_cur.execute("SELECT COUNT(*) FROM ce_warehouse.x_value")
    count = tgt_cur.fetchone()[0]
    if count > 0:
        raise Exception(f"Target values table is not empty! Found {count} records. Aborting.")

    # Build dates & periods
    print("Setting up dates and periods...")
    tgt_cur.execute("CALL ce_warehouse.px_ut_generate_dates()")


# -------------------------------------------------------
# Individual table copy functions
# -------------------------------------------------------

def migrate_avalue(src_cur, tgt_cur):
    src = "SELECT * FROM ce_powerbi.x_values_audit"
    tgt = "ce_warehouse.a_x_value"
    tmp = "t__xvalues_audit"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
            fk_pk_series, pdi, itype, isource, value, new_value, realised, audit_type, audit_utc)
            SELECT 
                x.fk_pk_xs::INT, x.pdi::INT, x.type::INT, s.pk_source, x.value::NUMERIC, 
                x.new_value::NUMERIC, x.realised::BOOL, x.aud_type, x.aud_utc::TIMESTAMPTZ
            FROM {tmp} x
                JOIN ce_warehouse.l_source s
                    ON s.code = x.source
            ORDER BY idx
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_calc(src_cur, tgt_cur):
    """Various jiggery pokery needed."""
    src = "SELECT * FROM ce_data.c_api_calc"
    tgt = "ce_warehouse.c_calc"
    tmp = "t__api_calc"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    # Insert into target "DX"
    tgt_cur.execute(f"""
        INSERT INTO {tgt} (tgt_series_id, tgt_cfreq, tgt_ctype, formula_type, expr, internal_notes, updated_utc)
            SELECT 
                ca_target_series,
                UNNEST(ca_target_freq::TEXT[]),
                'AC',
                'DX',
                ca_formula_type || '(#' || ca_source_series || '#,' || ca_source_freq || ')',
                CASE 
                    WHEN internal_notes ~ '^Auto.*generated' THEN NULL 
                    ELSE internal_notes 
                END,
                updated_utc::TIMESTAMPTZ
            FROM {tmp}
            WHERE error IS NULL
            ORDER BY pk_api_calc::INT
    """)

    # Now, we're gonna get the "calc" formulas
    src = "SELECT * FROM ce_data.c_calc"
    tgt = "ce_warehouse.c_calc"
    tmp = "t__calc"

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    formulas_regex = '^(ann|calc|delta|growth|offset|peop|pmean|pmedian|psum|quantile|zscore)\('

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (tgt_series_id, tgt_cfreq, tgt_ctype, formula_type, expr, internal_notes, updated_utc)
            SELECT 
                calc_series,
                calc_freq,
                UNNEST(
					CASE calc_type
					    WHEN 'BLENDED' THEN ARRAY['AC', 'F']
					    ELSE ARRAY[calc_type] 
					END
				),
                COALESCE(
                    SUBSTRING(calc_formula FROM '{formulas_regex}'), 
                    'basic'),
                calc_formula,
                internal_notes,
                updated_utc::TIMESTAMPTZ
            FROM {tmp}
            WHERE error IS NULL
            ORDER BY pk_calc::INT
            ON CONFLICT (tgt_series_id, tgt_cfreq, tgt_ctype) DO NOTHING
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_com(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_com"
    tgt = "ce_warehouse.c_com"
    tmp = "t__com"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (pk_com, code, name, short_name, tla, commodity_type, ordering, internal_notes, updated_utc)
            SELECT 
                c.pk_com::INT, c.com_code, c.com_name, c.com_short_name, c.com_tla, lt.pk_com_type, 
                c.com_order::INT, c.internal_notes, c.updated_utc::TIMESTAMPTZ
            FROM {tmp} c
               LEFT JOIN ce_warehouse.l_com_type lt
                    ON lt.name = c.com_type
            WHERE c.error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_const(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_const"
    tgt = "ce_warehouse.c_const"
    tmp = "t__const"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (pk_const, code, expr, value, internal_notes, updated_utc)
            SELECT pk_con::INT, con_code, con_expr, value::NUMERIC, internal_notes, updated_utc::TIMESTAMPTZ
            FROM {tmp}
            WHERE error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def data_clean_geo(tgt_cur, tmp):
    # Data cleansing
    fields = ["geo_name", "geo_name2", "geo_short_name"]
    names = {
        "China *": "China",
        "Curaçao": "Curacao",
        "Saint Barthélemy": "Saint Barthelemy"
    }
    for old, new in names.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = %s WHERE {fld} = %s"
            tgt_cur.execute(sql, (new, old))

    # Also remove multiple spaces
    for fld in fields:
        sql = f"UPDATE {tmp} SET {fld} = TRIM(REGEXP_REPLACE({fld}, '\\s+', ' ', 'g')) WHERE {fld} ~ '\\s{{2,}}'"
        tgt_cur.execute(sql, (new, old))

    fields = ["geo_flag"]
    flags = {
        "2022-12/Brazil%2flag.png": "2022-12/Brazil flag.png",
        "2022-12/Czech%2Republic_flag.png": "2022-12/Czech Republic flag.png",
        "2022-12/germany%2flag.png": "2022-12/germany flag.png",
        "2022-12/New%2Zealand_flag.png": "2022-12/New Zealand flag.png",
        "2022-12/Saudi%2Arabia_flag.png": "2022-12/Saudi Arabia flag.png",
        "2022-12/South%2Africa_flag.png": "2022-12/South Africa flag.png",
    }
    for old, new in flags.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = %s WHERE {fld} = %s"
            tgt_cur.execute(sql, (new, old))

    # @todo - discuss with Rhydian
    fields = ["geo_iso2"]
    iso2 = {
        "WLD": "WW"
    }
    for old, new in iso2.items():
        for fld in ["geo_iso2"]:
            sql = f"UPDATE {tmp} SET {fld} = %s WHERE {fld} = %s"
            tgt_cur.execute(sql, (new, old))


def migrate_geo(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_geo"
    tgt = "ce_warehouse.c_geo"
    tmp = "t__geo"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    # Data cleansing
    data_clean_geo(tgt_cur, tmp)

    # Insert into target
    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                pk_geo, code, name, name2, short_name, tla, iso2, iso3, lat, long, 
                central_bank, stock_market, political_alignment, local_currency_unit, flag, 
                category, ordering, internal_notes, updated_utc)
            SELECT 
                g.pk_geo::INT, g.geo_code, g.geo_name, g.geo_name2, g.geo_short_name, g.geo_tla, 
                g.geo_iso2, g.geo_iso3, g.geo_lat::NUMERIC, g.geo_long::NUMERIC, lcb.pk_central_bank,
                lsm.pk_stock_market, lpa.pk_political_alignment, lcu.code, g.geo_flag, lgc.pk_geo_category, 
                g.geo_order::INT, g.internal_notes, g.updated_utc::TIMESTAMPTZ
            FROM {tmp} g
                LEFT JOIN ce_warehouse.l_central_bank lcb
                    ON lcb.name = g.geo_cb
                LEFT JOIN ce_warehouse.l_stock_market lsm
                    ON lsm.name = g.geo_stockmarket
                LEFT JOIN ce_warehouse.l_political_alignment lpa
                    ON lpa.name = g.geo_political_alignment
                LEFT JOIN ce_warehouse.l_currency_unit lcu
                    ON lcu.code = g.geo_lcu
                LEFT JOIN ce_warehouse.l_geo_category lgc
                    ON lgc.name = g.geo_catg
            WHERE g.error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_geo_group(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_geo"
    tgt = "ce_warehouse.c_geo_group"
    tmp = "t__geo_group"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (fk_pk_geo, group_id, updated_utc)
            SELECT g.pk_geo, lgp.pk_geo_group, g.updated_utc
            FROM (
                SELECT DISTINCT 
                    pk_geo::INT, 
                    UNNEST(geo_groups::TEXT[]) AS code, 
                    updated_utc::TIMESTAMPTZ
                FROM {tmp}
                WHERE geo_groups IS NOT NULL
                AND error IS NULL
            ) g
                LEFT JOIN ce_warehouse.l_geo_group lgp
                    ON lgp.code = g.code
            WHERE g.code IS NOT NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def data_clean_ind(tgt_cur, tmp):
    # Data cleansing
    fields = ["i_name", "i_description", "i_name1", "i_name2", "i_name3", "i_name4"]
    names = {
        "\\": "",
        "all": "All",
        "average": "Average",
        "budget deficit": "Budget deficit",
        "buyer enquiries": "Buyer enquiries",
        "demand-supply": "Demand-supply",
        "ex. banks": "Ex. banks",
        "ex. Banks & BoE": "Ex. Banks & BoE",
        "Over 2 years'": "Over 2 years",
        "price expectations": "Price expectations",
        "r-g": '"r-g"',
        "rental demand-supply": "Rental demand-supply",
        "temporary sickness": "Temporary sickness",
        "#VALUE!": "",
        "y/y thousands": "Y/Y Thousands",
        "z-score": "Z-score",
    }
    for old, new in names.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = %s WHERE {fld} = %s"
            tgt_cur.execute(sql, (new, old))

    # Odds & sods
    fields += ["i_name_lower", "i_name1_lower", "i_name2_lower", "i_name3_lower", "i_name4_lower"]
    replacements = {
        ",$": "",
        "’": "'",
        "years'$": "years",

    }
    for old, new in replacements.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = REGEXP_REPLACE({fld}, %s, %s, 'i') WHERE {fld} ~* %s"
            tgt_cur.execute(sql, (old, new, old))

    # Also remove multiple spaces
    for fld in fields:
        sql = f"UPDATE {tmp} SET {fld} = TRIM(REGEXP_REPLACE({fld}, '\\s+', ' ', 'g')) WHERE {fld} ~ '\\s{{2,}}'"
        tgt_cur.execute(sql)


def migrate_ind(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_ind"
    tgt = "ce_warehouse.c_ind"
    tmp = "t__ind"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    # Data cleansing
    data_clean_ind(tgt_cur, tmp)

    # Insert into target
    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                pk_ind, code, name, description, name1, name2, name3, name4, name_lower, 
                name1_lower, name2_lower, name3_lower, name4_lower, category_broad, category_narrow,
                data_transformation, keyindicator, proprietary_data,
                ordering, internal_notes, updated_utc)
            SELECT 
                i.pk_i::INT, i.i_code, i_name, i.i_description, i.i_name1, i.i_name2, i.i_name3, i.i_name4,
                i.i_name_lower, i.i_name1_lower, i.i_name2_lower, i.i_name3_lower, i.i_name4_lower, 
                lbc.pk_ind_broad_category, lnc.pk_ind_narrow_category, i.i_data_transformation, 
                i.i_keyindicator::BOOL, i_proprietary_data::BOOL, i_order::INT, internal_notes, updated_utc::TIMESTAMPTZ
            FROM {tmp} i
                LEFT JOIN ce_warehouse.l_ind_broad_category lbc
                    ON lbc.name = i.i_catg_broad
                LEFT JOIN ce_warehouse.l_ind_narrow_category lnc
                    ON lnc.name = i.i_catg_narrow
            WHERE i.error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_ind_parent(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_ind"
    tgt = "ce_warehouse.c_ind_parent"
    tmp = "t__ind_parent"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (fk_pk_ind, icode, updated_utc)
            SELECT i.pk_i, i.code, i.updated_utc
            FROM (
                SELECT DISTINCT 
                    pk_i::INT, 
                    UNNEST(i_parent_icodes::TEXT[]) AS code, 
                    updated_utc::TIMESTAMPTZ
                FROM {tmp}
                WHERE i_parent_icodes IS NOT NULL
                AND error IS NULL
            ) i
            WHERE i.code IS NOT NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def data_clean_series(tgt_cur, tmp):
    # Consolidate "units"
    fields = ["s_units"]
    replacements = {
        "^\$bn": "$ bn",
        "^\$mn": "$ mn",
        "^\$US mn": "$ mn",
        "^£0": "£ 0",
        "^£bn": "£ bn",
        "^£m ": "£ mn ",
        "^£ Millions": "£ mn",
        "^€bn": "€ bn",
        "^€m ": "€ mn ",
        "^€ per Tonne": "€ per Tonne",
        "^000s ann\.": "000s ann.",
        "1966=100": "1966 = 100",
        "2015=100": "2015 = 100",
        "^Aus \$": "Aus$",
        "^(bps|Bps)": "BPS",
        "^EURmn": "EUR mn",
        "^euro mn, 2015 prices": "EURO mn (2015 prices)",
        "^Feb\.": "Feb",
        "2020( )?=( )?100": "2020 = 100",
        "^index": "Index",
        "^INRbn": "INR bn",
        "^Jan\.": "Jan",
        "^person": "Person",
        "^s$": "",
        "^s\.d\.": "S.D.",
        "^thousands": "Thousands",
        "^Thousands \(annual average\)": "Thousands, annual average",
        "^Thousands \(end of year\)": "Thousands, end of year",
        "^Thousands \(quarterly average\)": "Thousands, quarterly average",
        "^ton ": "TON",
        "^unit": "Unit",
        "^US\$bn": "US$ bn",
        "^US\$ bn, S\.A\.": "US$ bn (SA)",
        "^(Z|Z\-Scoree|z\-score)$": "Z-Score",
    }
    for old, new in replacements.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = REGEXP_REPLACE({fld}, %s, %s) WHERE {fld} ~* %s"
            tgt_cur.execute(sql, (old, new, old))

    # Data cleansing
    fields = ["s_name", "s_name1", "s_name2", "s_name3", "s_name4", "s_description", "s_source"]
    names = {
        "average": "Average",
        "Germany OIS-implied year-end policy rate (%, as of 30-01-2026": "Germany OIS-implied year-end policy rate (%, as of 30-01-2026)",
        "index": "Index",
        "Overnight Rate* (%)": "Overnight Rate (%)",
        "RBA Cash Rate* (%)": "RBA Cash Rate (%)",
        "US household debt (% of household income": "US household debt (% of household income)",
        "10 Yr GoC*., (%)": "10 Yr GoC. (%)",
        "1-year Loan Prime Rate (LPR)* %": "1-year Loan Prime Rate (LPR) %",
    }
    for old, new in names.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = %s WHERE {fld} = %s"
            tgt_cur.execute(sql, (new, old))

    # Odds & sods
    replacements = {
        "Barthélemy": "Barthelemy",
        "Curaçao": "Curacao",
        "^self": "Self",
        "^senior": "Senior",
        "years'$": "years",
        "^z\-score": "Z-score",
        "\(end-period$": "(end-period)",
        "\(%, end-period$": "(%, end-period)",
        "\^": "",
        "’": "'",
        "[,*]$": "",
        "(\)|Gilt|inflation|repo|Stock|Rate|Yield)([*]+)": "\\1",
    }
    for old, new in replacements.items():
        for fld in fields:
            sql = f"UPDATE {tmp} SET {fld} = REGEXP_REPLACE({fld}, %s, %s, 'i') WHERE {fld} ~* %s"
            tgt_cur.execute(sql, (old, new, old))

    # Also remove multiple spaces
    for fld in fields:
        sql = f"UPDATE {tmp} SET {fld} = TRIM(REGEXP_REPLACE({fld}, '\\s+', ' ', 'g')) WHERE {fld} ~ '\\s{{2,}}'"
        tgt_cur.execute(sql)


def migrate_series(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_series"
    tgt = "ce_warehouse.c_series"
    tmp = "t__series"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    data_clean_series(tgt_cur, tmp)

    # Insert into target
    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                pk_series, gcode, icode, name, name1, name2, name3, name4, description, 
                data_source, units, precision, date_point, active, 
                ordering, internal_notes, updated_utc)
            SELECT 
                s.pk_s::INT, s.s_gcode, s.s_icode, s.s_name, s.s_name1, s.s_name2, s.s_name3, s.s_name4,
                s.s_description, s.s_source, 
                CASE WHEN lu.pk_units IS NOT NULL THEN lu.pk_units WHEN s.s_units IS NOT NULL THEN -1 END, 
                s.s_precision::INT,s. s_date_point, s.s_active::BOOL,
                s.s_order::INT, s.internal_notes, s.updated_utc::TIMESTAMPTZ
            FROM {tmp} s
                LEFT JOIN ce_warehouse.l_units lu
                    ON lu.name = s.s_units
            WHERE error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_series_downloadable(src_cur, tgt_cur):
    src = "SELECT * FROM ce_data.c_series_metadata"
    tgt = "ce_warehouse.c_series_downloadable"
    tmp = "t__series_metadata"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                fk_pk_series, ifreq, itype, downloadable, forecast_only_lifespan, 
                internal_notes, updated_utc)
            SELECT 
                s.pk_series, f.pk_freq, t.pk_type, sm.sm_downloadable, sm.forecast_only_lifespan::INT,
                sm.internal_notes, sm.updated_utc::TIMESTAMPTZ
            FROM {tmp} sm
                JOIN ce_warehouse.c_series s 
                    ON s.gcode = sm.sm_gcode 
                    AND s.icode = sm.sm_icode
                JOIN ce_warehouse.l_freq f
                    ON f.code = sm.sm_freq
                JOIN ce_warehouse.l_type t
                    ON t.code = sm.sm_type
            WHERE sm.error IS NULL
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_xtooltip(src_cur, tgt_cur):
    src = "SELECT * FROM ce_pipeline.x_tooltip"
    tgt = "ce_warehouse.x_tooltip"
    tmp = "t__xtooltip"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (pk_tip, tooltip)
            SELECT pk_tip::INT, tooltip
            FROM {tmp}
            ORDER BY 1    
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def migrate_xvalue(src_cur, tgt_cur):
    tgt = "ce_warehouse.x_value"

    print(f"\n### MIGRATE: {tgt}")

    print("Disabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} DISABLE TRIGGER ALL")

    print("Truncating target table...")
    tgt_cur.execute(f"TRUNCATE TABLE {tgt} RESTART IDENTITY CASCADE")

    # We do this in 3 steps...

    # 1. x_api, API wins
    src = "SELECT * FROM ce_pipeline.x_api"
    tmp = "t__xapi"

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                fk_pk_series, pdi, itype, isource, value, fk_pk_tip, is_calculated, updated_utc)
            SELECT 
                x.fk_pk_s::INT, x.pdi::INT, x.type::INT, s.pk_source, x.value::NUMERIC, 
                x.fk_pk_tip::INT, (x.source = 'DX'), x.updated_utc::TIMESTAMPTZ
            FROM {tmp} x
                JOIN ce_warehouse.l_source s
                    ON s.code = x.source
            ORDER BY idx  
    """)

    # 2. x_manual
    src = "SELECT * FROM ce_pipeline.x_manual"
    tmp = "t__xmanual"

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                fk_pk_series, pdi, itype, isource, value, fk_pk_tip, is_calculated, updated_utc)
            SELECT 
                x.fk_pk_s::INT, x.pdi::INT, x.type::INT, s.pk_source, x.value::NUMERIC, 
                x.fk_pk_tip::INT, FALSE, x.updated_utc::TIMESTAMPTZ
            FROM {tmp} x
                JOIN ce_warehouse.l_source s
                    ON s.code = x.source
            ORDER BY idx
            ON CONFLICT (fk_pk_series, pdi) DO NOTHING 
    """)

    # 3. x_calc
    src = "SELECT * FROM ce_pipeline.x_manual"
    tmp = "t__xcalc"

    create_temp_from_source(src_cur, tgt_cur, src, tmp)
    copy_table(src_cur, tgt_cur, src, tmp)

    tgt_cur.execute(f"""
        INSERT INTO {tgt} (
                fk_pk_series, pdi, itype, isource, value, is_calculated, updated_utc)
            SELECT 
                x.fk_pk_s::INT, x.pdi::INT, x.type::INT, s.pk_source, x.value::NUMERIC, 
                TRUE, x.updated_utc::TIMESTAMPTZ
            FROM {tmp} x
                JOIN ce_warehouse.l_source s
                    ON s.code = x.source
            ORDER BY idx
            ON CONFLICT (fk_pk_series, pdi) DO NOTHING 
    """)

    print("Re-enabling triggers...")
    tgt_cur.execute(f"ALTER TABLE {tgt} ENABLE TRIGGER ALL")


def update_xseries_meta(src_cur, tgt_cur):
    """
    Post-migration updates to x-series metadata based on new values.
    """
    print("\n### POST-MIGRATION: Updating xseries metadata...")

    tgt_cur.execute("""
        INSERT INTO ce_warehouse.x_series_meta (
            fk_pk_series, ifreq, itype, sid1, first_pdi, last_pdi, has_values, updated_values_utc)
            SELECT
                x.fk_pk_series, x.ifreq, x.itype, s.sid1, MIN(x.pdi), MAX(x.pdi), TRUE, MAX(x.updated_utc) 
            FROM ce_warehouse.x_value x
                JOIN ce_warehouse.c_series s 
                     ON s.pk_series = x.fk_pk_series
            GROUP BY x.fk_pk_series, x.ifreq, x.itype, s.sid1
            ON CONFLICT (fk_pk_series, ifreq, itype) DO NOTHING
    """)

# -------------------------------------------------------
# Main migration
# -------------------------------------------------------

def main():
    src_conn = psycopg2.connect(**SOURCE_CONN)
    tgt_conn = psycopg2.connect(**TARGET_CONN)

    src_cur = src_conn.cursor()
    tgt_cur = tgt_conn.cursor()

    os.system('cls' if platform.system() == 'Windows' else 'clear')

    try:
        setup_and_check(src_cur, tgt_cur)

        migrate_com(src_cur, tgt_cur)
        migrate_geo(src_cur, tgt_cur)
        migrate_geo_group(src_cur, tgt_cur)
        migrate_ind(src_cur, tgt_cur)
        migrate_ind_parent(src_cur, tgt_cur)
        migrate_series(src_cur, tgt_cur)
        migrate_series_downloadable(src_cur, tgt_cur)
        migrate_const(src_cur, tgt_cur)
        migrate_calc(src_cur, tgt_cur)
        migrate_xtooltip(src_cur, tgt_cur)
        migrate_xvalue(src_cur, tgt_cur)
        migrate_avalue(src_cur, tgt_cur)

        update_xseries_meta(src_cur, tgt_cur)

        tgt_conn.commit()
        print("\n### Migration complete ✔")

    except Exception as e:
        tgt_conn.rollback()
        print("Migration failed:", e)
        raise

    finally:
        src_cur.close()
        tgt_cur.close()
        src_conn.close()
        tgt_conn.close()


if __name__ == "__main__":
    main()