/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for "ce_warehouse" (shared) data tables & associated functionality.
 ***********************************************************************************************************
 */

DROP SCHEMA IF EXISTS ce_warehouse CASCADE;  -- comment out once not needed for development, be careful with this!!

CREATE SCHEMA IF NOT EXISTS ce_warehouse;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_warehouse
    IS 'CE: ETL schema, tables & functionality';

-- REVOKE ALL ON SCHEMA ce_warehouse FROM public;

-- GRANT USAGE ON SCHEMA ce_warehouse TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_warehouse TO pgadmin842;