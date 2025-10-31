USE [test_enyu]

SELECT 'DROP TABLE IF EXISTS ['+[name]+']' FROM SYS.tables

DROP TABLE IF EXISTS [detail]
DROP TABLE IF EXISTS [header]
DROP TABLE IF EXISTS [header_DA_server_staging]
DROP TABLE IF EXISTS [detail_DA_server_staging]
DROP TABLE IF EXISTS [header_DA_server_main]
DROP TABLE IF EXISTS [detail_DA_server_main]