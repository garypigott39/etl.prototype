/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for PowerBi "core" internal tables & associated functionality.
 ***********************************************************************************************************
 */

DROP SCHEMA IF EXISTS ce_powerbi CASCADE;

CREATE SCHEMA IF NOT EXISTS ce_powerbi;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_powerbi
    IS 'CE: powerbi "core" internal tables & functionality';

-- REVOKE ALL ON SCHEMA ce_powerbi FROM public;

-- GRANT USAGE ON SCHEMA ce_powerbi TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_powerbi TO pgadmin842;