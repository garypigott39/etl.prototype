/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_name.sql
 *
 * Validation function - check if supplied string meets "simple name" rules.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_name;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_name(
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
    ELSEIF LENGTH(_val) = 1 AND _val !~ '[A-Z0-9]' THEN
        RETURN 'Single character value must be an uppercase letter (A-Z) or digit (0-9)';
    ELSEIF _val !~ '^[A-Z][A-Za-z0-9 &/:,.''()£$-]*[A-Za-z0-9).]$' THEN
        RETURN 'Value doesnt match "simple name" format';
    ELSEIF _val ~ '\s{2,}' THEN
        RETURN 'Value must not contain consecutive whitespace characters';
    ELSEIF _val !~ '^(?:[^()]|\([^()]*\))*$' THEN
        RETURN 'Value contains unbalanced parentheses';
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_name
    IS 'Validation function - check if supplied string meets "simple name" rules';
