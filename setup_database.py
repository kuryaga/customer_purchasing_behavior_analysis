
import csv
import sqlite3
from pathlib import Path

folder = Path(__file__).parent

connection = sqlite3.connect(folder / "customers.db")

with open(folder / "data" / "Customer Purchasing Behaviors.csv", newline="", encoding="utf-8-sig") as file:
    reader = csv.DictReader(file)
    rows = list(reader)

connection.execute("DROP TABLE IF EXISTS customers")

connection.execute("""
CREATE TABLE customers (
    user_id INTEGER,
    age INTEGER,
    annual_income REAL,
    purchase_amount REAL,
    loyalty_score REAL,
    region TEXT,
    purchase_frequency INTEGER
)
""")

for row in rows:
    connection.execute(
        "INSERT INTO customers VALUES (?, ?, ?, ?, ?, ?, ?)",
        (
            int(row["user_id"]),
            int(row["age"]),
            float(row["annual_income"]),
            float(row["purchase_amount"]),
            float(row["loyalty_score"]),
            row["region"],
            int(row["purchase_frequency"])
        )
    )

connection.commit()
print(f"Imported {len(rows)} rows successfully!")
connection.close()
