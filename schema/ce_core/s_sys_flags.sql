/*
 ***********************************************************************************************************
 * @file
 * s_sys_flags.sql
 *
 * System table - assorted system flags.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_core.s_sys_flags;

CREATE TABLE IF NOT EXISTS ce_core.s_sys_flags
(
    code TEXT NOT NULL PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT NOT NULL,
    powerbi BOOL NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE ce_core.s_sys_flags
    IS 'System table - assorted system flags';

/**
 * Pre-populate with known values.
 */

INSERT INTO ce_core.s_sys_flags
VALUES
('ASCII-ONLY','FALSE','If set to "TRUE" then only allow ASCII text values in CSV files etc. Default is value is "FALSE".',FALSE),
('AUDIT','ON','Where available table auditing is enabled - disable by setting to "OFF". Default is "ON".',FALSE),
('CONSTRAINTS','ON','Ability to disable table constraints. Default value is "ON".',FALSE),
('DATE.MAX','+30 YEAR','Max date for date lookup table. This should be an INTERVAL value. Default is "+30 YEAR".',FALSE),
('DATE.MIN','1890-01-01','Minimum date for date lookup table, should be the beginning of a year',FALSE),
('DB.VERBOSE','OFF','App/DB verbose mode for local debug. Default value is "OFF".',FALSE),
('DS.TOKEN.URL','https://product.datastream.com/dswsclient/V1/DSService.svc/rest/GetToken','Datastream API - Get Token URL',FALSE),
('DS.DATE.URL','https://product.datastream.com/DSWSClient/V1/DSService.svc/rest/GetData','Datastream API - Get Data URL',FALSE),
('GEO.FLAG.BASEURL','https://www.capitaleconomics.com/sites/default/files/','Base URL for GEO flags. Note the trailing slash.',FALSE);
