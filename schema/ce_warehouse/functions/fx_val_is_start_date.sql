/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_start_date.sql
 *
 * Validation function - check if supplied date is the start date of a period.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_start_date;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_start_date(
    _dt DATE,
    _ifreq INT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _dt IS NULL OR _ifreq IS NULL THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Date or frequency cannot be null';
        END IF;
    ELSEIF _ifreq NOT IN (1, 2, 3, 4, 5) THEN
        RETURN 'Invalid frequency';
    ELSEIF _ifreq = 1 THEN
        NULL;  -- Daily frequency - any date is valid
    ELSEIF _ifreq =  2 THEN
        IF _dt <> date_trunc('WEEK', _dt) THEN
            RETURN 'Date must be the start of a week';
        END IF;
    ELSEIF _ifreq = 3 THEN
        IF _dt <> date_trunc('MONTH', _dt) THEN
            RETURN 'Date must be the start of a month';
        END IF;
    ELSEIF _ifreq = 4 THEN
        IF _dt <> date_trunc('QUARTER', _dt) THEN
            RETURN 'Date must be the start of a quarter';
        END IF;
    ELSEIF _dt <> date_trunc('YEAR', _dt) THEN
        RETURN 'Date must be the start of a year';
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_start_date
    IS 'Validation function - check if supplied date is the start date of a period';
