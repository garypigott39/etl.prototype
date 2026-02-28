# Table Triggers for CE ETL

Note, these are generic auditing triggers, other triggers for deletion prevention etc would be added to the table definition.


## Naming convention

The naming convention for the trigger files is: `tg_<table_name>__<before_or_after>_<priority>__<optional annotation>.sql`

where:
* `<table_name>` is the name of the table the trigger is associated with.
* `before_or_after` is either `before` or `after`, depending on when the trigger should be executed.
* `priority` is a number that determines the order in which the triggers are executed. The lower the number, the higher the priority. 
* `optional annotation` is an optional string that can be used to provide additional information about the trigger, such as its purpose or the type of audit it performs. This can be helpful for documentation and maintenance purposes.


## Other notes

We could include the SQL in the table definitions, but it is easier to maintain the triggers in separate files.

>  Separating them from the table definition SQL allows us to easily drop/recreate them, plus it is easier to maintain the SQL in separate files.
