import pandas as pd
import pyodbc
import re
import os
import time


# =============================
# 1. Helpers
# =============================

def clean_column(col: str) -> str:
    """Clean column names for SQL compatibility."""
    col = col.strip()
    col = col.replace(" ", "_").replace(".", "").replace("%", "Percent").replace("-", "_")
    col = re.sub(r"[^A-Za-z0-9_]", "", col)
    return col


def load_csv(file_path: str) -> pd.DataFrame:
    """Load CSV and clean only headers (values are untouched)."""
    df = pd.read_csv(file_path, dtype=str)
    df.columns = [clean_column(c) for c in df.columns]

    # Handle duplicates
    final = []
    count = {}
    for col in df.columns:
        if col in count:
            count[col] += 1
            final.append(f"{col}_{count[col]}")
        else:
            count[col] = 0
            final.append(col)

    df.columns = final
    return df


# =============================
# 2. Database Connection
# =============================

SERVER = r"DESKTOP-BRPE7R0\SQLEXPRESS"
DATABASE = "UFC-DataWareHouse"


def get_connection():
    """Create a SQL Server connection."""
    conn_str = f"""
        Driver={{ODBC Driver 17 for SQL Server}};
        Server={SERVER};
        Database={DATABASE};
        Trusted_Connection=yes;
        TrustServerCertificate=yes;
    """
    return pyodbc.connect(conn_str.strip())


# =============================
# 3. Insertion Logic
# =============================

def insert_bronze(df: pd.DataFrame, table: str):
    """Try fast insert, fall back to batch insert if needed."""
    df = df.astype(object).where(pd.notnull(df), None)

    cols = ",".join(df.columns)
    placeholders = ",".join("?" for _ in df.columns)
    sql = f"INSERT INTO bronze.{table} ({cols}) VALUES ({placeholders})"

    total = len(df)
    print(f"\n📥 Inserting {total} rows into bronze.{table} ...")

    # Try fast insert
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.fast_executemany = True

        cursor.executemany(sql, df.itertuples(index=False, name=None))
        conn.commit()

        print(f"✅ Fast insert completed: {total} rows.")
        cursor.close()
        conn.close()
        return

    except Exception as e:
        print(f"⚠️ Fast insert failed: {str(e)}")
        print("🔄 Switching to batch insert...\n")

    # Batch insert fallback
    batch_size = 1000
    inserted = 0

    conn = get_connection()
    cursor = conn.cursor()

    for start in range(0, total, batch_size):
        batch = df.iloc[start:start + batch_size]

        try:
            cursor.executemany(sql, batch.itertuples(index=False, name=None))
            conn.commit()
            inserted += len(batch)

            print(f"   ➤ Inserted batch {start}–{start + len(batch)}")

        except Exception as e:
            print(f"❌ Error inserting batch {start}: {e}")
            conn.rollback()

    cursor.close()
    conn.close()

    print(f"🎯 Batch insert complete — {inserted}/{total} rows inserted.\n")


# =============================
# 4. File Settings
# =============================

BASE_DIR = "C:/Users/Administrator/Desktop/UFC_ETL-pipeline"
DATA_DIR = os.path.join(BASE_DIR, "Datasets")


FILES = {
    "Events": "Events.csv",
    "Fighter_Stats": "Fighters Stats.csv",
    "Fighters": "Fighters.csv",
    "Fights": "Fights.csv",
}

FILES = {table: os.path.join(DATA_DIR, fname) for table, fname in FILES.items()}


# =============================
# 5. Runner
# =============================

print("⏳ Testing SQL Server connection...")
try:
    c = get_connection()
    print("✅ Connected successfully.\n")
    c.close()
except Exception as e:
    print(f"❌ Cannot connect: {e}")
    exit()

for table, path in FILES.items():
    if not os.path.exists(path):
        print(f"⚠️ Missing file: {path}")
        continue

    print(f"📂 Loading {table} ({path})...")
    df = load_csv(path)

    print(f"➡️ {df.shape[0]} rows × {df.shape[1]} columns")
    insert_bronze(df, table)

print("\n🏁 All ingestion tasks completed.")
