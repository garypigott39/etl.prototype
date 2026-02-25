#!/usr/bin/env python3
"""
sqlorder.py

Thanks to ChatGPT for initial implementation!

This is not suitable for production use, and can create a single SQL file with all the SQL in the correct order.
"""

import os
import platform
import psycopg
import sys

from dotenv import load_dotenv
from collections import deque
from pathlib import Path


class SqlOrder:

    OUTPUT_SQL = "SQLORDER.sql"
    OUTPUT_TXT = "SQLORDER.txt"

    TEMP_DB = "_monkeyboy"

    RETRYABLE_ERRORS = {
        "42P01",  # undefined_table
        "42883",  # undefined_function
        "42704",  # undefined_object / type
        "3F000",  # undefined_schema
    }

    def __init__(self, sql_directory: str, debug: bool = False):
        if env_file := '.env' if Path('.env').exists() else None:
            load_dotenv(env_file)
        else:
            print("WARNING: .env file not found. Using default connection settings.")

        # Remove any existing output files
        os.unlink(self.OUTPUT_SQL) if Path(self.OUTPUT_SQL).exists() else None
        os.unlink(self.OUTPUT_TXT) if Path(self.OUTPUT_TXT).exists() else None

        #
        self.base_connection_string = self.connection_string(dbname="postgres")
        self.temp_connection_string = self.connection_string(dbname=self.TEMP_DB)

        self.temp_db_created = False
        self.debug = debug

        if self.temp_db_exists():
            raise Exception(f"ERROR: Database '{self.TEMP_DB}' already exists. Please drop it before running this script.")

        if not Path(sql_directory).is_dir():
            raise Exception(f"ERROR: Provided path '{sql_directory}' is not a valid directory.")

        self.base_path = Path(sql_directory).resolve()

        self.files = list(self.base_path.rglob("*.sql"))
        if not self.files:
            raise Exception(f"ERROR: No .sql files found in the provided directory '{sql_directory}'.")

        # Sort files by their relative path to ensure consistent order across different runs and platforms
        self.files = sorted(
            self.files,
            key=lambda p: str(p.relative_to(self.base_path))
        )

        self.ordered_files = []

    @staticmethod
    def connection_string(dbname: str) -> str:
        """
        Build a PostgreSQL connection string from environment variables, with defaults for local development.

        :param dbname:
        :return: string
        """
        config = {
            "dbname": dbname,
            "user": os.getenv("DB_USER", "postgres"),
            "password": os.getenv("DB_PASSWORD", "postgres"),
            "host": os.getenv("DB_HOST", "localhost"),
            "port": os.getenv("DB_PORT", "5432"),
        }
        return " ".join(f"{k}={v}" for k, v in config.items())

    def create_temp_database(self) -> None:
        """
        Create temporary database for testing SQL file execution order.
        :return: None
        """
        with psycopg.connect(self.base_connection_string, autocommit=True) as conn:
            with conn.cursor() as cur:
                cur.execute(f"CREATE DATABASE {self.TEMP_DB}")

    def drop_temp_database(self) -> None:
        """
        Delete temporary database for testing SQL file execution order.
        :return: None
        """
        with psycopg.connect(self.base_connection_string, autocommit=True) as conn:
            with conn.cursor() as cur:
                # terminate active connections
                cur.execute("""
                    SELECT pg_terminate_backend(pid)
                    FROM pg_stat_activity
                    WHERE datname = %s
                """, (self.TEMP_DB,))
                cur.execute(f"DROP DATABASE IF EXISTS {self.TEMP_DB}")

    def is_retryable(self, error: psycopg.Error) -> bool:
        """
        Determine if an error is retryable based on its SQLSTATE code.
        :param error:
        :return:
        """
        return getattr(error, "sqlstate", None) in self.RETRYABLE_ERRORS

    def print_order(self) -> None:
        """
        Print the resolved order of SQL files to the console.
        :return: None
        """
        with open(self.OUTPUT_TXT, 'w', encoding="utf-8") as f:
            print("\n***** SQL Files in Resolved Order *****\n", file=f)
            for i, (filename, _) in enumerate(self.ordered_files, 1):
                print(f"{i:03d}: {filename}", file=f)
            print('***** END OF FILE *****', file=f)

        print(f"\nSQL File Order written to {self.OUTPUT_TXT}")

    def print_sql(self) -> None:
        """
        Print the combined SQL of all files in the resolved order to the console.
        :return: None
        """

        def _debug(filename: str) -> str:
            return f"""
                DO $$
                BEGIN
                    RAISE NOTICE 'Executing file: {filename}  @ %', TO_CHAR(clock_timestamp(), 'HH24:MI:SS');
                END
                $$;
            """.replace("    ", "")

        with open(self.OUTPUT_SQL, "w", encoding="utf-8") as f:
            print("\n/***** COMBINED SQL IN RESOLVED ORDER *****/\n", file=f)
            for i, (filename, file) in enumerate(self.ordered_files, 1):
                print(f"-- {i}. {filename} --", file=f)
                if self.debug:
                    print(_debug(filename), file=f)
                print(file.read_text(encoding='utf-8'), file=f)
                print("\n", file=f)
            print('/***** END OF COMBINED SQL *****/', file=f)

        print(f"\nCombined SQL written to {self.OUTPUT_SQL}")

    def resolve_sql_order(self) -> None:
        """
        Resolve the execution order of SQL files by attempting to execute them in a temporary database.
        :return: None
        """
        self.create_temp_database()
        self.temp_db_created = True

        remaining = deque(self.files)

        with psycopg.connect(self.temp_connection_string) as conn:
            while remaining:
                progress_made = False
                next_round = deque()

                while remaining:
                    file = remaining.popleft()
                    if self.run_sql(conn, file):
                        rel_path = str(file.relative_to(self.base_path))
                        print(f"✔ Applied: {rel_path}")

                        self.ordered_files.append((file.relative_to(self.base_path), file))
                        progress_made = True
                    else:
                        next_round.append(file)

                if not progress_made:
                    unresolved = [str(f.relative_to(self.base_path)) for f in next_round]
                    raise RuntimeError( f"Circular dependency detected.\nRemaining: {unresolved}")

                remaining = next_round

    def run_sql(self, conn, file: Path) -> bool:
        """
        Attempt to execute a SQL statement, returning True if successful or if it fails with a retryable error.
        :param conn:
        :param sql:
        :return: bool
        """
        try:
            with conn.transaction():
                conn.execute(file.read_text(encoding='utf-8'))
            return True
        except psycopg.Error as e:
            if self.is_retryable(e):
                return False
            # Else...
            raise RuntimeError(f"ERROR: Fatal error in {file}: {e}") from e

    def temp_db_exists(self) -> bool:
        """
        Check if the temporary database already exists to avoid conflicts.
        :return: bool
        """
        with psycopg.connect(self.base_connection_string) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (self.TEMP_DB,))
                return cur.fetchone() is not None


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        print("Usage: py sqlorder.py <parent_sql_directory> [--debug]")
        sys.exit(1)

    os.system('cls' if platform.system() == 'Windows' else 'clear')

    try:
        obj = SqlOrder(sys.argv[1], debug='--debug' in sys.argv)
        obj.resolve_sql_order()
        obj.print_order()
        obj.print_sql()
    except Exception as e:
        print(str(e))
        sys.exit(1)
    finally:
        if 'obj' in locals():
            if obj.temp_db_created:
                obj.drop_temp_database()
                print(f"\nTemporary database dropped successfully.")
            del obj
