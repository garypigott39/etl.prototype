/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for "core" (shared) data tables & associated functionality.
 ***********************************************************************************************************
 */

-- DROP SCHEMA IF EXISTS ce_core CASCADE;

CREATE SCHEMA IF NOT EXISTS ce_core;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_core
    IS 'CE: "core" (shared) data specific tables & functionality';

-- REVOKE ALL ON SCHEMA ce_core FROM public;

-- GRANT USAGE ON SCHEMA ce_core TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_core TO pgadmin842;