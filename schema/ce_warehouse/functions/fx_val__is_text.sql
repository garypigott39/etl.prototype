/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_text.sql
 *
 * Validation function - check if supplied string meets relevant "text" rules.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_text;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_text(
    _val TEXT,
    _col_name TEXT DEFAULT 'DEFAULT',
    _nulls_allowed BOOL DEFAULT TRUE,
    _rule TEXT DEFAULT 'T'
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _rec RECORD;
    _ignore_case BOOL;

BEGIN
    IF _rule NOT IN ('C', 'T', 'N') THEN
        RAISE EXCEPTION 'Invalid rule parameter % - must be "C", "T" or "N"', _rule;
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

    -- Ignore case is not relevant for "text" rules as they should be pretty lax anyway!
    IF _col_name LIKE '%.ignore_case' THEN
        _ignore_case := _rule <> 'T';
        _col_name := REPLACE(_col_name, '.ignore_case', '');
    ELSE
        _ignore_case := FALSE;
    END IF;

    -- Get the relevant rule
    SELECT * INTO _rec
    FROM ce_warehouse.s_text_rules
    WHERE rule_type = _rule
    AND column_name IN (_col_name, 'DEFAULT')
    ORDER BY
      CASE
        WHEN column_name = 'DEFAULT' THEN 1
        ELSE 0
      END
    LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No validation rule found for type % and column_name = %', _rule, _col_name;
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
        ELSEIF _ignore_case AND (
                    (NOT _rec.negate_regex AND _val !~* _rec.single_char_regex) OR
                    (_rec.negate_regex AND _val ~* _rec.single_char_regex)
            ) THEN
            RETURN 'Value does not match required format for single character (ignoring case)';
        ELSEIF NOT _ignore_case AND (
                    (NOT _rec.negate_regex AND _val !~ _rec.single_char_regex) OR
                    (_rec.negate_regex AND _val ~ _rec.single_char_regex)
            ) THEN
            RETURN 'Value does not match required format for single character';
        END IF;
    END IF;

    -- Check full regex
    IF LENGTH(_val) > 1 AND _rec.full_regex <> 'ANY' THEN
        IF _rec.full_regex = 'PRINTABLE' THEN
            IF _val !~ '^[[:print:]]+$' THEN
                RETURN 'Value contains unprintable characters';
            END IF;
        ELSEIF _rec.full_regex = 'ASCII' THEN
            IF _val !~ '^[[:ascii:]]+$' THEN
                RETURN 'Value contains non-ASCII characters';
            END IF;
        ELSEIF _ignore_case AND (
                    (NOT _rec.negate_regex AND _val !~* _rec.full_regex) OR
                    (_rec.negate_regex AND _val ~* _rec.full_regex)
            ) THEN
            RETURN 'Value does not match required format (ignoring case)';
        ELSEIF NOT _ignore_case AND (
               (NOT _rec.negate_regex AND _val !~ _rec.full_regex) OR
               (_rec.negate_regex AND _val ~ _rec.full_regex)
            ) THEN
            RETURN 'Value does not match required format';
        END IF;
    END IF;

    -- Consecutive whitespace
    IF NOT _rec.allow_consecutive_ws AND ( _val ~ '^\s' OR _val ~ '\s$' ) THEN
        RETURN 'Value must not contain consecutive whitespace characters';
    END IF;

    -- Leading/trailing whitespace
    IF NOT _rec.allow_leading_or_trailing_ws AND ( _val ~ '^\s' OR _val ~ '\s$' ) THEN
        RETURN 'Value must not start or end with whitespace';
    END IF;

    -- Unbalanced parentheses
    IF NOT _rec.allow_unbalanced_parenthesis THEN
        -- Simple check for balanced parentheses - count opening and closing
        IF LENGTH(REPLACE(_val, '(', '')) <> LENGTH(REPLACE(_val, ')', '')) THEN
            RETURN 'Value contains unbalanced parentheses';
        END IF;
    END IF;

    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_text
    IS 'Validation function -  check if supplied string meets relevant "text" rules';
