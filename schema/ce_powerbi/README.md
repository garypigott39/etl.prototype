# Schema: ce_powerbi

The ce_powerbi schema contains internal utilities and materialized views used to build the dimension and fact tables exposed in `ce_powerbi_v02`.

We intentionally separate these layers:

* `ce_powerbi` → Internal base layer (not exposed)

* `ce_powerbi_v02` → Presentation layer (exposed to Power BI)

Only the ce_powerbi_v02 schema is granted to the Power BI user. No other warehouse schemas — including `ce_powerbi` — are exposed.

This ensures a clean separation between transformation logic and reporting tables, while restricting Power BI access strictly to curated, presentation-ready data.


Enjoy!