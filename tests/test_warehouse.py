import shutil
import sqlite3
from pathlib import Path

import pytest

import customer360.build as warehouse
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


def test_failed_rebuild_preserves_existing_database(tmp_path: Path, monkeypatch):
    database = tmp_path / "warehouse.db"
    build(database, tmp_path / "exports")
    before = database.read_bytes()
    original = warehouse.run_sql

    def fail_during_load(connection, path):
        if path.name == "02_load.sql":
            raise RuntimeError("load failed")
        original(connection, path)

    monkeypatch.setattr(warehouse, "run_sql", fail_during_load)
    with pytest.raises(RuntimeError, match="load failed"):
        build(database, tmp_path / "exports")
    assert database.read_bytes() == before


def test_unknown_customer_fails_instead_of_dropping_line(tmp_path: Path, monkeypatch):
    source_root = Path(__file__).parents[1]
    shutil.copytree(source_root / "sql", tmp_path / "sql")
    shutil.copytree(source_root / "data/source", tmp_path / "data/source")
    transactions = tmp_path / "data/source/transactions.csv"
    lines = transactions.read_text(encoding="utf-8").splitlines()
    lines[1] = lines[1].replace(",C001,", ",UNKNOWN,")
    transactions.write_text("\n".join(lines) + "\n", encoding="utf-8")
    monkeypatch.setattr(warehouse, "ROOT", tmp_path)
    with pytest.raises(ValueError, match="transaction lines could not be loaded"):
        build(tmp_path / "warehouse.db", tmp_path / "exports")

