/*
 ***********************************************************************************************************
 * @file
 * px_ut__lock_or_unlock.sql
 *
 * Utility procedure - lock/unlock named pipeline (or whatever).
 ***********************************************************************************************************
 */

-- DROP PROCEDURE IF EXISTS ce_warehouse.px_ut__lock_or_unlock;

CREATE OR REPLACE PROCEDURE ce_warehouse.px_ut__lock_or_unlock(
    _name TEXT,
    _type TEXT DEFAULT 'lock',          -- lock | unlock
    _interval INTERVAL DEFAULT '1 hour'
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    _name := UPPER(TRIM(_name));
    _type := LOWER(TRIM(_type));

    IF _name IS NULL OR TRIM(_name) = '' THEN
        RAISE EXCEPTION 'Lock name must be provided';
    END IF;

    IF _type = 'lock' THEN
        -- Fail if active lock exists
        IF EXISTS (
            SELECT 1 FROM ce_warehouse.s__lock
            WHERE name = _name
            AND ts_locked_at > NOW() - _interval
        ) THEN
            RAISE EXCEPTION 'Pipeline "%" is already locked', _name;
        END IF;

        -- Insert or refresh lock
        INSERT INTO ce_warehouse.s__lock(name) VALUES (_name)
            ON CONFLICT (name)
            DO UPDATE SET ts_locked_at = NOW();

    ELSIF _type = 'unlock' THEN
        DELETE FROM ce_warehouse.s__lock
        WHERE name = _name;

    ELSE
        RAISE EXCEPTION 'Invalid type "%" - must be lock or unlock', _type;
    END IF;

    RAISE INFO 'Lock "%" %ed successfully', _name, _type;
END;
$$;

COMMENT ON PROCEDURE ce_warehouse.px_ut__lock_or_unlock
    IS 'Utility procedure - lock/unlock named pipeline (or whatever)';
