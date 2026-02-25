# Table Triggers for CE ETL

We could include the SQL in the table definitions, but it is easier to maintain the triggers in separate files.

>  Separating them from the table definition SQL allows us to easily drop/recreate them, plus it is easier to maintain the SQL in separate files.
