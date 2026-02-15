/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for "etl" (shared) data tables & associated functionality.
 ***********************************************************************************************************
 */

-- DROP SCHEMA IF EXISTS etl CASCADE;

CREATE SCHEMA IF NOT EXISTS etl;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA etl
    IS 'CE: ETL schema, tables & functionality';

-- REVOKE ALL ON SCHEMA etl FROM public;

-- GRANT USAGE ON SCHEMA etl TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA etl TO pgadmin842;