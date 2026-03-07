/*
 ***********************************************************************************************************
 * @file
 * fx_val__is_image.sql
 *
 * Validation function - check if supplied string meets "image" rules.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_val__is_image;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_val__is_image(
    _val TEXT,
    _nulls_allowed BOOL DEFAULT TRUE,
    _is_full_url BOOL DEFAULT FALSE
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
DECLARE
    _err TEXT;

BEGIN
    IF _is_full_url THEN
        _err := ce_warehouse.fx_val__is_url(_val, _nulls_allowed);
        IF _err IS NOT NULL THEN
            RETURN _err;
        END IF;
    END IF;

    RETURN ce_warehouse.fx_val__is_text(_val, 'image', _nulls_allowed, 'N');
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_val__is_image
    IS 'Validation function - check if supplied string meets "image" rules';
