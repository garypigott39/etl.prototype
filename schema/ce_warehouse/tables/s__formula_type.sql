/*
 ***********************************************************************************************************
 * @file
 * s_formula_type.sql
 *
 * System table - formula types.
 *
 * NOTE, we don't use the text validation functions in any of the "s_" system tables because they are
 * potentially used by the validation functions, so we need to have more basic validation rules in place
 * to avoid circular references.
 ***********************************************************************************************************
 */

-- DROP TABLE IF EXISTS ce_warehouse.s__formula_type;

CREATE TABLE IF NOT EXISTS ce_warehouse.s__formula_type
(
    code TEXT NOT NULL
        CHECK (code ~ '^[A-Za-z][A-Za-z0-9 ]*[A-Za-z0-9]$'),
    class TEXT
        CHECK (class ~ '^[A-Za-z][A-Za-z0-9\.]*[A-Za-z0-9]$'),  -- for CSS class names, e.g. in the UI, so allow apostrophes but not full stops or dashes
    description TEXT,
    ordering INT NOT NULL DEFAULT 0,  -- for ordering in UI
    
    PRIMARY KEY (code)
);

COMMENT ON TABLE ce_warehouse.s__formula_type
    IS 'System table - formula types';

/**
 * Pre-populate with known values. As we add new formula types, add them here.
 */
INSERT INTO ce_warehouse.s__formula_type (code, class, description, ordering)
VALUES
    ('DX', 'DX', 'Formula type for DX formulas, replaces old API calc functionality', -1);

INSERT INTO ce_warehouse.s__formula_type (code, class, description)
VALUES
    ('basic', 'basic', 'Basic expression, e.g. #SERIES1# + #SERIES2#'),
    ('ann', 'ann', 'Annualisation expression'),
    ('calc', 'calc', 'Calculation expression - supports sd, mean, median, etc'),
    ('delta', 'delta', 'Delta expression - compare periods for a change in value'),
    ('growth', 'growth', 'Growth expression - compare periods as a growth rate'),
    ('offset', 'offset', 'Offset expression'),
    ('peop', 'peop', 'End of period expression'),
    ('pmean', 'pmean', 'Period mean expression'),
    ('psum', 'psum', 'Period sum expression'),
    ('quantile', 'quantile', 'Quantile expression'),
    ('zscore', 'zscore', 'Z-score expression');
