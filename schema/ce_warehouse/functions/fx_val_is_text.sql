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
    _nulls_allowed BOOL DEFAULT FALSE
)
    RETURNS BOOL
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF ce_core.fx_ut_is_null(_val) THEN
        RETURN _nulls_allowed;
    ELSEIF _val !~ '^[[:print:]]+$' THEN
        -- Contains unprintable characters
        RETURN FALSE;
    ELSEIF _val !~ '^[[:ascii:]]+$' THEN
        -- Contains non-ASCII characters
        IF EXISTS (SELECT 1 FROM ce_core.s_sys_flags WHERE code = 'ASCII-ONLY' AND value = 'TRUE') THEN
            RETURN FALSE;
        END IF;
    END IF;

    -- Must not start or end with whitespace
    RETURN _val !~ '^\s' AND _val !~ '\s$';
END
$$;

COMMENT ON FUNCTION ce_core.fx_val_is_text
    IS 'Validation function - check supplied string meets "free-text" rules';
