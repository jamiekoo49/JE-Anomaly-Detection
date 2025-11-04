import pandas as pd
from _00_util_sql import Conn_ODBC
import os
from datetime import datetime

def export_table_to_csv(database_name, table_name, output_file_path=None):
    db_conn = Conn_ODBC(database=database_name)
    if not db_conn.odbc_validate_conn():
        print(f"Failed to connect to database: {database_name}")
        return None
    
    try:
        conn = db_conn.odbc_conn_db_pyodbc()
        sql_query = f"SELECT * FROM [{table_name}]"
        print(f"Exporting table '{table_name}' from database '{database_name}'...")
        df = db_conn.odbc_run_sql(conn, sql_query, return_result=True)
        conn.close()
        if output_file_path is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file_path = f"{database_name}_{table_name}_{timestamp}.csv"
        df.to_csv(output_file_path, index=False)
        
        print(f"Successfully exported {len(df)} rows to: {output_file_path}")
        print(f"Columns exported: {list(df.columns)}")
        
        return output_file_path
        
    except Exception as e:
        print(f"Error exporting table: {str(e)}")
        return None


def list_available_tables(database_name):
    db_conn = Conn_ODBC(database=database_name)
    
    if not db_conn.odbc_validate_conn():
        print(f"Failed to connect to database: {database_name}")
        return []
    
    tables = db_conn.get_list_of_tables_in_db()
    return tables

def export_tables_as_separate_files(database_name, table_names, output_folder=None):
    db_conn = Conn_ODBC(database=database_name)
    
    if not db_conn.odbc_validate_conn():
        print(f"Failed to connect to database: {database_name}")
        return []

    if output_folder and not os.path.exists(output_folder):
        os.makedirs(output_folder)
        print(f"Created output folder: {output_folder}")
    
    exported_files = []
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    try:
        conn = db_conn.odbc_conn_db_pyodbc()
        
        for table_name in table_names:
            print(f"\nExporting table: {table_name}")
            sql_query = f"SELECT * FROM [{table_name}]"
            df = db_conn.odbc_run_sql(conn, sql_query, return_result=True)
            
            if df is None or df.empty:
                print(f"  - Warning: No data found in table '{table_name}', skipping...")
                continue
            filename = f"{database_name}_{table_name}_{timestamp}.csv"
            if output_folder:
                file_path = os.path.join(output_folder, filename)
            else:
                file_path = filename
            df.to_csv(file_path, index=False)
            exported_files.append(file_path)
            
            print(f"  - Successfully exported {len(df)} rows to: {file_path}")
            print(f"  - Columns: {list(df.columns)}")
        conn.close()
        
        print(f"\n=== EXPORT SUMMARY ===")
        print(f"Total files created: {len(exported_files)}")
        for file in exported_files:
            print(f"  - {file}")
        return exported_files
    except Exception as e:
        print(f"Error exporting tables: {str(e)}")
        return []


if __name__ == "__main__":
    DATABASE_NAME = "JE_ML_2025"
    table_list = ["data_BW_2021", "data_BW_2022"]
    export_tables_as_separate_files(DATABASE_NAME, table_list)