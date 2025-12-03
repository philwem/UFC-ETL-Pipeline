import pandas as pd
import pyodbc as odbc
import re
import os
import time


# ---------- 1️⃣ Helpers ----------
def clean_column_name(col: str) -> str:
    """Clean column names minimally for SQL compatibility."""
    col = col.strip()
    col = col.replace(" ", "_").replace(".", "").replace(
        "%", "Percent").replace("-", "_")
    col = re.sub(r"[^a-zA-Z0-9_]", "", col)
    return col


def load_and_clean_headers(file_path: str) -> pd.DataFrame:
    """Read CSV and clean only headers (not values)."""
    df = pd.read_csv(file_path, dtype=str)
    df.columns = [clean_column_name(col) for col in df.columns]

    # Handle duplicate column names
    seen, new_cols = {}, []
    for col in df.columns:
        if col in seen:
            seen[col] += 1
            new_cols.append(f"{col}_{seen[col]}")
        else:
            seen[col] = 0
            new_cols.append(col)
    df.columns = new_cols
    return df


# ---------- 2️⃣ Database Connection ----------
SERVICE_NAME = "DESKTOP-BRPE7R0\SQLEXPRESS"
# PORT = "1433"
DATABASE_NAME = "UFC_DataWareHouse"
# USERNAME = "admin"
# PASSWORD = "UfcProj2025!"


def get_connection():
    """Establish new connection to RDS."""
    conn_str = f"""
        Driver={{ODBC Driver 17 for SQL Server}};
        Server=tcp:{SERVICE_NAME};
        Database={DATABASE_NAME};
        Trusted_Connection=yes;
        TrustServerCertificate=yes;
        Connection Timeout=30;
    """
    return odbc.connect(conn_str.strip())


def test_connection(conn):
    """Test if connection is still alive."""
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        return True
    except:
        return False


# ---------- 3️⃣ Fast Bulk Insert Function ----------
def insert_into_bronze(df: pd.DataFrame, table_name: str):
    """Insert DataFrame into Bronze tables in batches with persistent connection."""
    df = df.astype(object).where(pd.notnull(df), None)

    cols = ",".join(df.columns)
    placeholders = ",".join("?" for _ in df.columns)
    sql = f"INSERT INTO bronze.{table_name} ({cols}) VALUES ({placeholders})"

    batch_size = 1000  # Increased for better performance
    total_rows = len(df)
    inserted, skipped = 0, 0

    conn = get_connection()
    cursor = conn.cursor()

    print(f"\n📥 Inserting into bronze.{table_name} ({total_rows} rows)...")

    for start in range(0, total_rows, batch_size):
        batch = df.iloc[start:start + batch_size]
        batch_end = start + len(batch)

        for attempt in range(3):
            try:
                # Test connection health before executing
                if attempt > 0 or not test_connection(conn):
                    print("🔄 Reconnecting...")
                    try:
                        conn.close()
                    except:
                        pass
                    conn = get_connection()
                    cursor = conn.cursor()

                # Execute batch insert
                cursor.executemany(
                    sql, batch.itertuples(index=False, name=None))
                conn.commit()
                inserted += len(batch)
                print(f"✅ Batch {start}-{batch_end} inserted.")
                break

            except Exception as e:
                error_msg = str(e)
                print(
                    f"⚠️ Batch {start}-{batch_end} attempt {attempt+1}/3 failed")

                # Safe rollback
                try:
                    conn.rollback()
                except:
                    pass

                # Check if it's a connection issue
                if "Communication link failure" in error_msg or "TCP Provider" in error_msg or "08S01" in error_msg:
                    wait_time = 3 * (attempt + 1)
                    print(f"   Connection lost. Retrying in {wait_time}s...")
                    time.sleep(wait_time)
                elif attempt == 2:
                    skipped += len(batch)
                    print(
                        f"❌ Batch {start}-{batch_end} skipped after 3 attempts.")
                else:
                    time.sleep(1)

    try:
        cursor.close()
        conn.close()
    except:
        pass

    print(
        f"🎯 {table_name} upload complete: {inserted} inserted, {skipped} skipped.\n")


# ---------- 4️⃣ Alternative: Single Transaction Insert ----------
def insert_into_bronze_fast(df: pd.DataFrame, table_name: str):
    """Ultra-fast single transaction insert (use for smaller tables)."""
    df = df.astype(object).where(pd.notnull(df), None)

    cols = ",".join(df.columns)
    placeholders = ",".join("?" for _ in df.columns)
    sql = f"INSERT INTO bronze.{table_name} ({cols}) VALUES ({placeholders})"

    total_rows = len(df)

    print(f"\n📥 Fast insert into bronze.{table_name} ({total_rows} rows)...")

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # Fast insert with progress indicator
        cursor.fast_executemany = True
        cursor.executemany(sql, df.itertuples(index=False, name=None))
        conn.commit()
        print(f"✅ All {total_rows} rows inserted in single transaction.")
    except Exception as e:
        print(f"❌ Fast insert failed: {e}")
        conn.rollback()
        print("   Falling back to batched insert...")
        cursor.close()
        conn.close()
        insert_into_bronze(df, table_name)
        return
    finally:
        try:
            cursor.close()
            conn.close()
        except:
            pass

    print(f"🎯 {table_name} upload complete: {total_rows} inserted.\n")


# ---------- 5️⃣ File Paths ----------
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "Datasets")

files_tables = {
    "Events": os.path.join(DATA_DIR, "Events.csv"),
    "Fighter_Stats": os.path.join(DATA_DIR, "Fighters Stats.csv"),
    "Fighters": os.path.join(DATA_DIR, "Fighters.csv"),
    "Fights": os.path.join(DATA_DIR, "Fights.csv"),
}


# ---------- 6️⃣ Run Process ----------
print("⏳ Connecting to SQLEXPRESS...")
try:
    test_conn = get_connection()
    print("✅ Connected to SQLEXPRESS SQL Server\n")
    test_conn.close()
except Exception as e:
    print(f"❌ Initial connection failed: {e}")
    exit()

# Use fast insert for all tables
for table, file in files_tables.items():
    if not os.path.exists(file):
        print(f"⚠️ File not found: {file}")
        continue

    df = load_and_clean_headers(file)
    print(f"📂 Loading: {file}")
    print(f"➡ {df.shape[0]} rows × {df.shape[1]} columns")

    # Try fast insert first, falls back to batched if it fails
    insert_into_bronze_fast(df, table)

print("🏁 All ingestion tasks completed successfully!")
