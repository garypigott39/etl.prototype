/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for Excel "plugin" tables & views.
 ***********************************************************************************************************
 */

DROP SCHEMA IF EXISTS ce_plugin CASCADE;

CREATE SCHEMA IF NOT EXISTS ce_plugin;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_plugin
    IS 'CE: plugin "exposed" tables & views';

-- REVOKE ALL ON SCHEMA ce_powerbi FROM public;

-- GRANT USAGE ON SCHEMA ce_powerbi TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_powerbi TO pgadmin842;