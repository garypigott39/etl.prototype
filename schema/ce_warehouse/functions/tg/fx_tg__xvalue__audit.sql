/*
 ***********************************************************************************************************
 * @file
 * fx_tg__xvalue__audit.sql
 *
 * Trigger function - log changes in x_value to custom audit table (AFTER update).
 ***********************************************************************************************************
 */

-- DROP FUNCTION IF EXISTS ce_warehouse.fx_tg__xvalue__audit;

CREATE OR REPLACE FUNCTION ce_warehouse.fx_tg__xvalue__audit(
)
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    _now TIMESTAMPTZ := NOW();

BEGIN
   -- Trigger disabled?
    IF NOT ce_warehouse.fx_ut__trigger_is_enabled(TG_NAME) THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    IF TG_OP = 'INSERT' THEN

        /***************************************************************************
         * INSERT
         ***************************************************************************/

        INSERT INTO ce_warehouse.a__xvalue (
            fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, is_realised, audit_type, audit_user
        )
        VALUES (
            NEW.fk_pk_series,
            NEW.lk_pk_pdi,
            NEW.itype,
            NEW.lk_pk_source,
            NEW.value,
            FALSE,
            'I',
            ce_warehouse.fx_ut__current_uid()
        );

    ELSEIF TG_OP = 'UPDATE' THEN

        /***************************************************************************
         * UPDATE
         ***************************************************************************/

        IF (OLD.value IS DISTINCT FROM NEW.value)
            OR (OLD.itype IS DISTINCT FROM NEW.itype)
            OR (OLD.lk_pk_source IS DISTINCT FROM NEW.lk_pk_source) THEN

            INSERT INTO ce_warehouse.a__xvalue (
                fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, new_value, is_realised, audit_type, audit_user
            )
            VALUES (
                OLD.fk_pk_series,
                OLD.lk_pk_pdi,
                OLD.itype,
                OLD.lk_pk_source,
                OLD.value,
                NEW.value,
                (OLD.itype = 2 AND NEW.itype = 1),
                'U',
                ce_warehouse.fx_ut__current_uid()
            );

        END IF;

    ELSEIF TG_OP = 'DELETE' THEN

        /***************************************************************************
         * DELETE
         ***************************************************************************/

        INSERT INTO ce_warehouse.a__xvalue(
           fk_pk_series, lk_pk_pdi, itype, lk_pk_source, value, is_realised, audit_type, audit_user
        )
        VALUES (
            OLD.fk_pk_series,
            OLD.lk_pk_pdi,
            OLD.itype,
            OLD.lk_pk_source,
            OLD.value,
            FALSE,
            'D',
            ce_warehouse.fx_ut__current_uid()
        );

    END IF;

    -- No need to return a record since this is an AFTER trigger
    RETURN NULL;
END
$$;

COMMENT ON FUNCTION ce_warehouse.fx_tg__xvalue__audit
    IS 'Trigger function - log changes in x_value to custom audit table (AFTER update)';
