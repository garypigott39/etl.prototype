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
    _col_name TEXT DEFAULT 'DEFAULT',
    _nulls_allowed BOOL DEFAULT TRUE,
    _text_or_name TEXT DEFAULT 'T'
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _rec RECORD;
    _ignore_case BOOL;

BEGIN
    IF _text_or_name NOT IN ('T', 'N') THEN
        RAISE EXCEPTION 'Invalid text_or_name parameter % - must be "T" or "N"', _text_or_name;
    END IF;

    -- Basic checks for NULL/empty and unprintable/non-ASCII characters
    IF _val IS NULL OR TRIM(_val) = '' THEN
        IF NOT _nulls_allowed THEN
            RETURN 'Value cannot be null or empty';
        END IF;
        RETURN NULL;
    ELSEIF _val !~ '^[[:print:]]+$' THEN
        -- Contains unprintable characters
        RETURN 'Value contains unprintable characters';
    ELSEIF _val !~ '^[[:ascii:]]+$' THEN
        -- Contains non-ASCII characters
        IF EXISTS (SELECT 1 FROM ce_warehouse.s_sys_flags WHERE code = 'ASCII-ONLY' AND value = 'TRUE') THEN
            RETURN 'Value contains non-ASCII characters';
        END IF;
    END IF;

    -- ignore case is only relevant for "name" rules
    IF _col_name LIKE '%.ignore_case' THEN
        _ignore_case := _text_or_name = 'N';
        _col_name := REPLACE(_col_name, '.ignore_case', '');
    ELSE
        _ignore_case := FALSE;
    END IF;

    -- Get the relevant rule
    SELECT * INTO _rec
    FROM ce_warehouse.s_text_rules
    WHERE text_or_name = _text_or_name
    AND column_name IN (_col_name, 'DEFAULT')
    ORDER BY
      CASE
        WHEN column_name = 'DEFAULT' THEN 1
        ELSE 0
      END
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No validation rule found for text_or_name = % and column_name = %', _text_or_name, _col_name;
    END IF;

    -- Check length
    IF LENGTH(_val) < _rec.min_length THEN
        RETURN FORMAT('Value must be at least %s characters long', _rec.min_length);
    ELSIF LENGTH(_val) > _rec.max_length THEN
        RETURN FORMAT('Value must be no more than %s characters long', _rec.max_length);
    END IF;

    -- Check single character regex if applicable
    IF LENGTH(_val) = 1 AND _rec.single_char_regex <> 'ANY' THEN
        IF _rec.single_char_regex = 'PRINTABLE' THEN
            IF _val !~ '^[[:print:]]+$' THEN
                RETURN 'Value contains unprintable characters';
            END IF;
        ELSEIF _rec.single_char_regex = 'ASCII' THEN
            IF _val !~ '^[[:ascii:]]+$' THEN
                RETURN 'Value contains non-ASCII characters';
            END IF;
        ELSEIF _ignore_case AND _val !~* _rec.single_char_regex THEN
            RETURN 'Value does not match required format for single character (ignoring case)';
        ELSEIF val !~ _rec.single_char_regex THEN
            RETURN 'Value does not match required format for single character';
        END IF;
    END IF;

    -- Check full regex
    IF LENGTH(_val) > 1 AND _rec.full_regex = 'ANY' THEN
        IF _rec.full_regex = 'PRINTABLE' THEN
            IF _val !~ '^[[:print:]]+$' THEN
                RETURN 'Value contains unprintable characters';
            END IF;
        ELSEIF _rec.full_regex = 'ASCII' THEN
            IF _val !~ '^[[:ascii:]]+$' THEN
                RETURN 'Value contains non-ASCII characters';
            END IF;
        ELSEIF _ignore_case AND _val !~* _rec.full_regex THEN
            RETURN 'Value does not match required format (ignoring case)';
        ELSEIF val !~ _rec.full_regex THEN
            RETURN 'Value does not match required format';
        END IF;
    END IF;

    -- Consecutive whitespace
    IF _rec.allow_consecutive_ws = FALSE AND ( _val ~ '^\s' OR _val ~ '\s$' ) THEN
        RETURN 'Value must not contain consecutive whitespace characters';
    END IF;

    -- Leading/trailing whitespace
    IF _rec.allow_leading_or_trailing_ws = FALSE AND ( _val ~ '^\s' OR _val ~ '\s$' ) THEN
        RETURN 'Value must not start or end with whitespace';
    END IF;

    -- Unbalanced parentheses
    IF _rec.allow_unbalanced_parentheses = FALSE AND _val !~ '^(?:[^()]|\([^()]*\))*$' THEN
        RETURN 'Value contains unbalanced parentheses';
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val_is_text
    IS 'Validation function - check supplied string meets "free-text" rules';
