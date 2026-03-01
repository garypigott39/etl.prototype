# Schema: ce_warehouse

This schema contains tables related to the CE warehouse & ETL process.


## Naming Conventions

_Typically: double underscore separates metadata from object name._

| Prefix            | Category / Type           | Example                       | Notes                                                      |
|-------------------|---------------------------|-------------------------------|------------------------------------------------------------|
| Stored procedures |                           |                               |                                                            |
| `px_pl__`         | Pipeline stored procedure | `px_pl__daily_housekeeping`   | Pipeline procedure, related tasks                          |
| `px_ut__`         | Stored procedure utility  | `px_ut__lock_pipeline`        | Procedure utility                                          |
| Functions         |                           |                               |                                                            |
| `fx_tb__`         | Table-returning function  | `fx_tb__table_cols`           | Function returning a table                                 |
| `fx_tg__`         | Trigger function          | `fx_tg__cseries__soft_delete` | Trigger function                                           |
| `fx_ut__`         | Function utility          | `fx_ut__trim`                 | Function utility helper                                    |
| `fx_val__`        | Function validation       | `fx_ut__is_text`              | Function validation helper                                 |
| Tables            |                           |                               |                                                            |
| `a__`             | Audit / history table     | `a__xvalue`                   | Audit table                                                |
| `c__`             | Control / metadata        | `c__workflow_status`          | Configuration, control, or metadata table                  |
| `l__`             | Lookup table              | `l__central_bank`             | Lookup table                                               |
| `s__`             | System tables             | `s__sys_flag`                 | System table                                               |
| `u__`             | User data / raw input     | `u__value`                    | Raw data, coming from users or external sources            |
| `x__`             | Internal / auxiliary      | `x__value`                    | Internal use, not directly exposed to consumers            |
| Triggers          |                           |                               |                                                            |
| `tg__`            | Before trigger            | `tg__cseries__b01`            | This example is an initial before action on table c_series |
|                   |                           |                               |                                                            |
| Views             |                           |                               |                                                            |
| `mv__`            | Materialized view         | `mv__xvalue`                  | Any materialized view                                      |
| `v__`             | View                      | `v__date`                     | Any view                                                   |

### Column names

| Prefix   | Category / Type | Example              | Notes                                                                     |
|----------|-----------------|----------------------|---------------------------------------------------------------------------|
| `pk__`   | Primary key     | `pk_freq`            | Primary key, that is intended to be used as a foreign key in other tables |
| `idx`    | Primary key     | `idx_date`           | Primary key, that is **not** useful as a foreign key                      | 
| `fk__`   | Foreign key     | `fk_pk_pdi`          | Foreign key, that references a primary key in another table               |
| `lk__`   | Foreign key     | `fk_pk_pdi`          | Foreign key, to lookup table                                              |
| `is__`   | Boolean flag    | `is_active`          | Boolean flag, typically used for soft deletes or status indicators        |
| `dt__`   | Date            | `dt_start_of_period` | Date column, typically used for tracking creation or modification         |


Enjoy!
