import pyodbc
import sqlalchemy
import pandas as pd
import os
from warnings import filterwarnings
import urllib
import json   # to handle lists

from sqlalchemy.dialects.mssql.base import MSDialect
from sqlalchemy import inspect
from sqlalchemy.types import NVARCHAR, Integer, Float, Boolean, DateTime, Numeric


class Conn_ODBC:

    def __init__(self, database=""):
        filterwarnings("ignore", category=UserWarning, message='.*pandas only supports SQLAlchemy connectable.*')

        self.server="DA-SERVER"
        self.server_ip="192.168.10.50"
        self.username="victoriaquek"
        self.password="Kpmg@12345678"
        self.database=database


    def odbc_validate_conn(self):
        #  DRIVER=ODBC Driver 17 for SQL Server;
        conn_string = f"""
             DRIVER=SQL Server;
             SERVER={self.server_ip};
             DATABASE={self.database};
             UID={self.username};
             PWD={self.password};
             Trusted_Connection=no;
        """
        
        try: 
            pyodbc.connect(conn_string, autocommit=True)
            print("Connection success...")
            return True
        except: 
            print("Connection failed.")
            return False
        
    
    def odbc_conn_db_sqlalchemy(self):
        ##############################
        # SQL ALCHEMY
        ##############################
        ##### Parse username & password in case of special characters 
        username=urllib.parse.quote_plus(self.username)
        password=urllib.parse.quote_plus(self.password) 
        database="master" if self.database=="" else self.database
        ##### Connect
        connection_url=f"mssql+pyodbc://{username}:{password}@{self.server_ip}/{database}?driver=SQL+Server"
        engine=sqlalchemy.create_engine(connection_url, fast_executemany=True)
        conn=engine.connect()
        
        return engine, conn
    
    def custom_has_table(self, connection, table_name, schema=None):
        schema = schema or 'dbo'
        query = f"""
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = '{table_name}' AND TABLE_SCHEMA = '{schema}'
        """
        result = connection.execute(query)
        return result.scalar() > 0


    def odbc_conn_db_pyodbc(self):
        # conn=pyodbc.connect(self.conn_string, autocommit=True)
        # cursor=conn.cursor()
        ###############################
        # PYODBC
        ###############################
        database="master" if self.database=="" else self.database
        conn_str = (
            r'DRIVER={SQL Server};'
            rf'SERVER={self.server_ip};'
            rf'DATABASE={database};'
            rf'UID={self.username};'
            rf'PWD={self.password};'
        )
        conn = pyodbc.connect(conn_str)

        return conn


    def odbc_run_sql(self, conn, sql_query, return_result=False):
        try: 
            if return_result: 
                ### FETCH AND RETURN SQL QUERY RESULTS
                df=pd.read_sql(sql_query, conn)

                ###################################
                # DESERIALIZE JSON STRINGS TO LISTS
                ###################################
                for col in df.columns:
                    def try_json_loads(x):
                        if isinstance(x, str):
                            try:
                                return json.loads(x)
                            except json.JSONDecodeError:
                                return x  # Not a JSON string, leave unchanged
                        else:
                            return x  # Not a string, leave unchanged

                    # Apply only to non-null values
                    df[col] = df[col].apply(lambda x: try_json_loads(x) if pd.notna(x) else x)

                return df
            
            else: 
                ### RUN SQL QUERY WITHOUT RETURNING RESULTS
                # sql_query=sqlalchemy.text(sql_query)
                cursor=conn.cursor()
                cursor.execute(sql_query)
                conn.commit()
                
        except:   # Exception as e
            print("\n>>>>>>>>>>>>>>>>>>> ERROR ENCOUNTERED IN SQL QUERY <<<<<<<<<<<<<<<<<<<")
            print(sql_query)
            print("========================================================================")
            # return e  # Optionally return error for debugging


    def get_list_of_authorised_db(self):
        """
        Fetches a list of all databases where the user is assigned. 
        """
        conn=self.odbc_conn_db_pyodbc()

        ######################################
        # Get all DB in Server
        ######################################
        sql_query="SELECT DISTINCT [NAME] FROM [SYS].[DATABASES] ORDER BY [NAME]"
        df_all_db=self.odbc_run_sql(conn, sql_query, return_result=True)
        list_all_db=df_all_db["NAME"].tolist()
        
        ######################################
        # Check for assigned DBs
        ######################################
        ##### GET UNION OF ALL DATABASE PRINCIPALS: DB + SID 
        list_sql_query_db_principals=[]
        for db in list_all_db: 
            list_sql_query_db_principals.append(f"SELECT '{db}' AS [database], [sid] FROM [{db}].[SYS].[DATABASE_PRINCIPALS]")
        sql_query_db_principals=" UNION ".join(list_sql_query_db_principals)
        ##### JOIN IN USERNAME
        sql_query=f"""
            SELECT A.[database]
            FROM ({sql_query_db_principals}) [A] 
            LEFT JOIN [SYS].[SERVER_PRINCIPALS] [B] 
            ON [A].[SID]=[B].[SID] 
            WHERE [B].[name]='{self.username}'
            AND A.[database] NOT IN ('master','model','msdb','tempdb','resource')
        """
        df_check_db=self.odbc_run_sql(conn, sql_query, return_result=True)

        conn.close()

        if df_check_db.empty:
            return []
        else: 
            return df_check_db["database"].tolist()


    def get_list_of_tables_in_db(self):
        """
        Fetches a list of all tables in a database. 
        """ 

        if self.database=="": 
            return []
        else: 
            conn=self.odbc_conn_db_pyodbc()
            sql_query=f"SELECT [NAME] FROM [{self.database}].[sys].[tables] ORDER BY [NAME]"
            df_tables_in_db=self.odbc_run_sql(conn, sql_query, return_result=True)
            conn.close()
            return df_tables_in_db["NAME"].tolist()


    def get_list_of_columns_in_table(self, table_name):
        """
        Fetches a list of all columns in a table. 
        """ 

        if self.database=="": 
            return []
        else: 
            conn=self.odbc_conn_db_pyodbc()
            sql_query=f"SELECT b.[NAME] FROM [{self.database}].[sys].[tables] A LEFT JOIN [{self.database}].[sys].[columns] B ON A.[object_id]=B.[object_id] WHERE A.[name]='{table_name}' ORDER BY [column_id]"
            df_tables_in_db=self.odbc_run_sql(conn, sql_query, return_result=True)
            conn.close()
            return df_tables_in_db["NAME"].tolist()

 
    def fn_create_new_table_from_df(self, table_name: str, df: pd, auto_data_type: True):
        """
        Reads a file, uses columns to create a table with all nvarchar(max) datatype. 
        Adds 2 columns: ["Data Import: Source Folder","Data Import: Source File"]
        If False, create new table based on default options when reading file. 
        """
        ###################################
        # DROP IF EXIST
        ###################################
        conn=self.odbc_conn_db_pyodbc()
        sql_drop_table=f"DROP TABLE IF EXISTS [{table_name}]"
        self.odbc_run_sql(conn, sql_drop_table, return_result=False)
        conn.close()
        # engine,_=self.odbc_conn_db_sqlalchemy()

        try:
            # df_empty = df.iloc[:0].copy()  # Empty DataFrame with same schema
            # print(df_empty.info())

            if auto_data_type: 
                ###################################
                # AUTO DATA TYPE - USE SQL ALCHEMY TO CREATE NEW TABLE
                ###################################
                # Define NVARCHAR(4000) for all columns
                engine,conn_sqlalchemy=self.odbc_conn_db_sqlalchemy()
                # dtype = {col: sqlalchemy.types.NVARCHAR(4000) for col in df.columns}

                def generate_sqlalchemy_dtypes(df: pd.DataFrame):
                    dtype_map = {}
                    # Common columns that should be treated as high-precision decimals (customize as needed)
                    decimal_cols = {"price", "amount", "cost", "revenue", "salary"}  # Customize based on your use case

                    for col in df.columns:
                        col_dtype = df[col].dtype

                        if pd.api.types.is_integer_dtype(col_dtype):
                            dtype_map[col] = Integer()
                        elif pd.api.types.is_float_dtype(col_dtype):
                            # Optionally map specific cols to Numeric
                            # if col.lower() in decimal_cols:
                                # dtype_map[col] = Numeric(precision=18, scale=4)
                            # else:
                                dtype_map[col] = Float()
                        elif pd.api.types.is_bool_dtype(col_dtype):
                            dtype_map[col] = Boolean()
                        elif pd.api.types.is_datetime64_any_dtype(col_dtype):
                            dtype_map[col] = DateTime()
                        elif pd.api.types.is_object_dtype(col_dtype):
                            # Assume string; could add logic to infer decimals
                            dtype_map[col] = NVARCHAR(length=4000)
                        else:
                            dtype_map[col] = NVARCHAR(length=4000)

                    return dtype_map

                dtype=generate_sqlalchemy_dtypes(df)
                print(dtype)

                df.to_sql(name=table_name, con=engine, schema="dbo", if_exists="replace", index=False, dtype=dtype)
                
            else:
                ###################################
                # NON-AUTO DATA TYPE - CREATE TABLE SET AS NVARCHAR
                ###################################
                conn_pyodbc=self.odbc_conn_db_pyodbc()
                ##### Get list of columns
                list_headers=list(df.columns)
                ##### Get query to create table 
                list_headers.extend(["Data Import: Source Folder","Data Import: Source File"])
                list_headers=[str(header).strip(" ,.'").replace(".","-") for header in list_headers]
                sql_column_definition=[f"[{header}] nvarchar(max)" for header in list_headers]
                sql_column_definition=",\n".join(sql_column_definition)
                sql_create_table=f"CREATE TABLE [{table_name}] ({sql_column_definition})"
                ##### Create table
                self.odbc_run_sql(conn_pyodbc, sql_create_table, return_result=False)
                conn_pyodbc.close()
                pass

        except Exception as e:
            raise e
        
        finally:
            engine.dispose()


    def fn_append_df_to_table(self, table_name: str, df: pd):
        """
        Insert data from df into database table
        """
        try:
            ###################################
            # INIT CONN
            ###################################
            conn=self.odbc_conn_db_pyodbc()
            cursor = conn.cursor()

            ###################################
            # GET DF COLS & VALUES 
            ###################################
            # df = df.fillna("").copy()  # To prevent Fragmentation
            df = df.mask(df.isna(), None).copy()   # To handle NaT and NULL and None 

            # Serialize list-containing columns to JSON strings
            for col in df.columns:
                if df[col].apply(lambda x: isinstance(x, list)).any():  # Check if any value is a list
                    df[col] = df[col].apply(lambda x: json.dumps(x) if isinstance(x, list) else x)
            
            list_col=self.get_list_of_columns_in_table(table_name)
            list_data = df.values.tolist()

            ###################################
            # INSET DF TO TABLE
            ###################################
            column_name = ""
            values = ""

            for key in list_col:
                column_name += "[" + str(key) + "], "
                values += "?,"

            sql_string = (
                f"INSERT INTO [{table_name}] ("
                + column_name[:-2]
                + ") VALUES ("
                + values[:-1]
                + ")"
            )

            cursor.fast_executemany = True
            cursor.executemany(sql_string, iter(list_data))
            
            conn.commit()
            conn.close()

            return True
        
        except Exception as e: 
            return e


if __name__ == "__main__":
    x=Conn_ODBC(database="JE_ML_2025")
    df=pd.DataFrame({
        'name': ['Alice', 'Bob', 'Charlie', 'David'],
        'age': [25, 30, 22, 28],
        'city': ['New York', 'London', 'Paris', 'Tokyo']
    })
    print(df.reset_index(drop=True))

    x.fn_create_new_table_from_df(table_name="test", df=df, auto_data_type=True)