/*
 ***********************************************************************************************************
 * @file
 * px_ut__enable_or_disable_trigger.sql
 *
 * Utility procedure - enable/disable named trigger.
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__enable_or_disable_trigger;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__enable_or_disable_trigger(
    _name TEXT,
    _type TEXT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    _name := LOWER(TRIM(_name));
    _type := LOWER(TRIM(_type));

    IF _name IS NULL OR _type IS NULL THEN
        RAISE EXCEPTION 'Trigger name and type must be provided';
    ELSEIF _name !~ 'tg__[a-z0-9_]+[a-z0-9]$' THEN
        RAISE EXCEPTION 'Invalid trigger name format: "%". Must match tg__[a-z0-9_]+[a-z0-9]', _name;
    ELSEIF _type = 'disable' THEN
        INSERT INTO ce_warehouse.s__trigger_status (
           name, status
        )
        VALUES (_name, 'disabled')
        ON CONFLICT (name)
            DO NOTHING;
    ELSIF _type = 'enable' THEN
        DELETE FROM ce_warehouse.s__trigger_status
        WHERE name = _name;
    ELSE
        RAISE EXCEPTION 'Invalid type: "%". Must be enable or disable', _type;
    END IF;

    RAISE INFO 'Trigger "%" status updated', _name;
END;
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__enable_or_disable_trigger
    IS 'Utility procedure - enable/disable named trigger';
