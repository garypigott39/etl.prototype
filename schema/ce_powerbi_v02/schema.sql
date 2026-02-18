/*
 ***********************************************************************************************************
 * @file
 * schema.sql
 *
 * Schema for PowerBi "exposed" tables & associated functionality. VERSION #2
 ***********************************************************************************************************
 */

DROP SCHEMA IF EXISTS ce_powerbi_v02 CASCADE;

CREATE SCHEMA IF NOT EXISTS ce_powerbi_v02;
--     AUTHORIZATION pgadmin842;

COMMENT ON SCHEMA ce_powerbi_v02
    IS 'CE: powerbi "exposed" internal tables & functionality. VERSION #2';

-- REVOKE ALL ON SCHEMA ce_powerbi_v02 FROM public;

-- GRANT USAGE ON SCHEMA ce_powerbi_v02 TO azuredatafactoryuser;
-- GRANT ALL ON SCHEMA ce_powerbi_v02 TO pgadmin842;