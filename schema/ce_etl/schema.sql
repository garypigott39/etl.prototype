/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for "ce_etl" (shared) data tables & associated functionality.
 ***********************************************************************************************************
 */

DROP SCHEMA IF EXISTS ce_etl CASCADE;  -- comment out once not needed for development, be careful with this!!

CREATE SCHEMA IF NOT EXISTS ce_etl;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_etl
    IS 'CE: ETL schema, tables & functionality';

-- REVOKE ALL ON SCHEMA ce_etl FROM public;

-- GRANT USAGE ON SCHEMA ce_etl TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_etl TO pgadmin842;