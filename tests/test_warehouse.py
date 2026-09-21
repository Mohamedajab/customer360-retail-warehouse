import sqlite3
from pathlib import Path

from customer360.build import build


def test_builds_balanced_star_schema(tmp_path: Path):
    database = tmp_path / "warehouse.db"
    build(database, tmp_path / "exports")
    connection = sqlite3.connect(database)
    facts = connection.execute("SELECT COUNT(*) FROM fact_sales").fetchone()[0]
    source = connection.execute("SELECT COUNT(*) FROM stage_transactions").fetchone()[0]
    gross, returns, net = connection.execute(
        "SELECT SUM(gross_revenue), SUM(return_value), SUM(net_revenue) FROM fact_sales"
    ).fetchone()
    assert facts == source == 14
    assert round(gross - returns, 2) == round(net, 2)


def test_views_answer_customer_and_product_questions(tmp_path: Path):
    database = tmp_path / "warehouse.db"
    build(database, tmp_path / "exports")
    connection = sqlite3.connect(database)
    repeat = connection.execute(
        "SELECT COUNT(*) FROM vw_customer_summary WHERE is_returning_customer = 1"
    ).fetchone()[0]
    products = connection.execute("SELECT COUNT(*) FROM vw_product_performance").fetchone()[0]
    assert repeat == 5
    assert products == 5

