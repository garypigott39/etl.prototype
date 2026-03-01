# Table Triggers for CE ETL

Note, these are generic auditing triggers, other triggers for deletion prevention etc would be added to the table definition.


## Other notes

We could include the SQL in the table definitions, but it is easier to maintain the triggers in separate files.

>  Separating them from the table definition SQL allows us to easily drop/recreate them, plus it is easier to maintain the SQL in separate files.


Enjoy!
