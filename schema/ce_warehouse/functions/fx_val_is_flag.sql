/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_flag.sql
 *
 * Validation function - check if supplied string meets "simple flag" rules.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_flag;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_flag(
    _val TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _val IS NULL OR TRIM(_val) = '' THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Value cannot be null or empty';
        END IF;
    ELSEIF _val !~ '^(?!https?://)[\w\-/ ]+\/?[\w\-]+\.(jpg|jpeg|png|gif|webp)$' THEN
        RETURN 'Value doesnt match "simple flag" format';
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_flag
    IS 'Validation function - check if supplied string meets "simple flag" rules';
