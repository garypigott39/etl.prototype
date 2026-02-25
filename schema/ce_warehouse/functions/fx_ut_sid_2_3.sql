/*
 ***********************************************************************************************************
 * @file
 * fx_ut_sid_2_3.sql
 *
 * Utility function - generate SID 2 / SID 3 code.
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_ut_sid_2_3;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_ut_sid_2_3(
    _pks INT,
    _ifreq INT,
    _itype INT DEFAULT NULL
)
    RETURNS TEXT
    LANGUAGE plpgsql
    IMMUTABLE
AS
$$
DECLARE
    _sid TEXT;
BEGIN
    IF _pks IS NULL OR _ifreq IS NULL THEN
        RETURN NULL;
    ELSEIF _ifreq NOT IN (1, 2, 3, 4, 5) THEN
        RETURN NULL;
    ELSEIF _itype IS NOT NULL AND _itype NOT IN (1, 2) THEN
        RETURN NULL;
    END IF;

    _sid := (SELECT sid1 FROM ce_warehouse.c_series WHERE pk_series = _pks);
    IF _sid IS NULL THEN
        RETURN NULL;
    END IF;

    IF _ifreq IN (1, 2, 3, 4, 5) THEN
        _sid := _sid || '_' || (SELECT code FROM ce_warehouse.l_freq WHERE pk_freq = _ifreq);
    END IF;

    IF _itype IS NOT NULL THEN
        _sid := _sid || '_' || (SELECT code FROM ce_warehouse.l_type WHERE pk_type = _itype);
    END IF;

    RETURN _sid;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_ut_sid_2_3
    IS 'Utility function - generate SID 2 / SID 3 code';
