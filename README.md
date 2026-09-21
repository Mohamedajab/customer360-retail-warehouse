# Customer360 — retail warehouse and BI model

Customer360 is a small star schema built around questions a retail manager actually asks:
Which regions are growing? Which products sell but come back? How much revenue comes from
people who return for another order?

The repository uses SQLite so the complete warehouse is reproducible in seconds. The SQL
is deliberately portable: the schema, load and views translate cleanly to Azure SQL,
PostgreSQL or SQL Server with minor datatype changes.

## Quick start

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
python -m pip install -e ".[dev]"
customer360 --database customer360.db --export-dir exports
pytest -q
```

Open the database with any SQLite client or load the three generated CSVs from `exports/`
into Power BI.

## Design decisions

- The sales fact is one order line, not one order. Product totals therefore stay honest.
- Returns are stored as quantity and value; gross and net revenue remain explainable.
- Dates and dimension members are resolved during the load, enforcing referential integrity.
- Reporting views stabilise the contract consumed by BI tools.
- Source tables remain present for simple lineage and reconciliation in this demonstration.

See [the model](docs/model.md), [analysis queries](sql/analysis.sql), and the
[dashboard wireframe](docs/dashboard-wireframe.md).

## Suggested production extension

Land source snapshots outside the warehouse, load through transient staging tables, and
record a batch ID on every fact row. Add effective dates to dimensions only when the
business needs historical attribute reporting. More machinery is not automatically a
better model.

