"""Build and seed the Customer360 SQLite demonstration warehouse."""

from __future__ import annotations

import argparse
import csv
import sqlite3
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def run_sql(connection: sqlite3.Connection, path: Path) -> None:
    connection.executescript(path.read_text(encoding="utf-8"))


def load_csv(connection: sqlite3.Connection, path: Path, table: str) -> int:
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        return 0
    columns = list(rows[0])
    placeholders = ",".join("?" for _ in columns)
    connection.executemany(
        f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders})",
        ([row[column] or None for column in columns] for row in rows),
    )
    return len(rows)


def seed_dates(connection: sqlite3.Connection, start: date, end: date) -> None:
    current = start
    rows = []
    while current <= end:
        rows.append((
            int(current.strftime("%Y%m%d")), current.isoformat(), current.day,
            current.strftime("%B"), current.month, (current.month - 1) // 3 + 1,
            current.year, current.strftime("%A"), int(current.weekday() >= 5),
        ))
        current += timedelta(days=1)
    connection.executemany("INSERT INTO dim_date VALUES (?,?,?,?,?,?,?,?,?)", rows)


def export_query(connection: sqlite3.Connection, query: str, path: Path) -> None:
    cursor = connection.execute(query)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([column[0] for column in cursor.description])
        writer.writerows(cursor.fetchall())


def build(database: Path, export_dir: Path) -> None:
    if database.exists():
        database.unlink()
    connection = sqlite3.connect(database)
    connection.execute("PRAGMA foreign_keys = ON")
    try:
        run_sql(connection, ROOT / "sql/01_schema.sql")
        seed_dates(connection, date(2025, 1, 1), date(2025, 12, 31))
        source = ROOT / "data/source"
        load_csv(connection, source / "customers.csv", "stage_customers")
        load_csv(connection, source / "products.csv", "stage_products")
        load_csv(connection, source / "transactions.csv", "stage_transactions")
        run_sql(connection, ROOT / "sql/02_load.sql")
        run_sql(connection, ROOT / "sql/03_views.sql")
        connection.commit()
        export_query(connection, "SELECT * FROM vw_monthly_performance", export_dir / "monthly_performance.csv")
        export_query(connection, "SELECT * FROM vw_customer_summary", export_dir / "customer_summary.csv")
        export_query(connection, "SELECT * FROM vw_product_performance", export_dir / "product_performance.csv")
    finally:
        connection.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Build the Customer360 demonstration warehouse")
    parser.add_argument("--database", type=Path, default=ROOT / "customer360.db")
    parser.add_argument("--export-dir", type=Path, default=ROOT / "exports")
    args = parser.parse_args()
    build(args.database, args.export_dir)
    print(f"Built {args.database} and exported reporting views to {args.export_dir}")


if __name__ == "__main__":
    main()

