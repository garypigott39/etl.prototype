/*
 ***********************************************************************************************************
 * @file
 * u_tooltip.sql
 *
 * Userdata table - updates to the values tooltip field & lookup.
 *
 * Note, there is no error or update_type fields here as we either accept the tooltip or not, and if we
 * want to unset a tooltip we just set it to "undef" and then it is removed from the target table.
 * Also, there is no PDI or PKS field on the table as the number of tooltips is very small so we just
 * lookup the value in the app.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.u__tooltip;

CREATE TABLE IF NOT EXISTS ce_warehouse.u__tooltip
(
    idx INT GENERATED ALWAYS AS IDENTITY,

    ut_gcode TEXT,
    ut_icode TEXT,
    ut_period TEXT,
    ut_freq TEXT,  -- CHAR version of frequency
    ut_tooltip TEXT,

    file_name TEXT, -- File it came from, if applicable
    error TEXT,  -- system generated

    PRIMARY KEY (idx)
);

COMMENT ON TABLE ce_warehouse.u__tooltip
    IS 'Userdata table - updates to the values tooltip field & lookup';
