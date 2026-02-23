/*
 ***********************************************************************************************************
 * @file
 * fx_val_is_text.sql
 *
 * Validation function - check if supplied string meets "free text" rules.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val_is_text;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val_is_text(
    _val TEXT,
    _nulls_allowed BOOL DEFAULT TRUE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _val IS NULL OR TRIM(_val) = '' THEN
        RETURN _nulls_allowed ? NULL : 'Value cannot be null or empty';
    ELSEIF _val !~ '^[[:print:]]+$' THEN
        -- Contains unprintable characters
        RETURN 'Value contains unprintable characters';
    ELSEIF _val !~ '^[[:ascii:]]+$' THEN
        -- Contains non-ASCII characters
        IF EXISTS (SELECT 1 FROM ce_core.s_sys_flags WHERE code = 'ASCII-ONLY' AND value = 'TRUE') THEN
            RETURN 'Value contains non-ASCII characters';
        END IF;
    END IF;

    -- Must not start or end with whitespace
    RETURN _val !~ '^\s' AND _val !~ '\s$' ? NULL : 'Value must not start or end with whitespace';
END
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_text
    IS 'Validation function - check supplied string meets "free-text" rules';
