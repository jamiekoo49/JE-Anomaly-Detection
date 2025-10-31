
--=====================================
-- Copy key tables, from damien
--=====================================
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_COA_All]					FROM [Hailong_P2P].[dbo].[staging_COA_All]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_COA_HL2]					FROM [Hailong_P2P].[dbo].[staging_Chart_of_Accounts_HL2]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_COA_HL3]					FROM [Hailong_P2P].[dbo].[staging_Chart_of_Accounts_HL3]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_JE_updated_All]			FROM [Hailong_P2P].[dbo].[staging_JE_updated_All]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_JE_updated_HL2]			FROM [Hailong_P2P].[dbo].[staging_JE_updated_HL2]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_JE_updated_HL3]			FROM [Hailong_P2P].[dbo].[staging_JE_updated_HL3]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Payment_List_All]		FROM [Hailong_P2P].[dbo].[Staging_Payment List All]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Payment_List_HL2]		FROM [Hailong_P2P].[dbo].[Staging_Payment List HL2]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Payment_List_HL3]		FROM [Hailong_P2P].[dbo].[Staging_Payment List HL3]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Trial_Balance_HL2_2024]	FROM [Hailong_P2P].[dbo].[Staging_Trial Balance_HL2_2024]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Trial_Balance_HL3_2024]	FROM [Hailong_P2P].[dbo].[Staging_Trial Balance_HL3_2024]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Vendors_All]				FROM [Hailong_P2P].[dbo].[staging_Vendors All]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Vendors_HL2]				FROM [Hailong_P2P].[dbo].[staging_Vendors HL2]
--SELECT * INTO [test_enyu].[dbo].[refHL_staging_Vendors_HL3]				FROM [Hailong_P2P].[dbo].[staging_Vendors HL3]


--=====================================
-- view 
--=====================================

USE [Hailong_P2P]


SELECT 'SELECT TOP 100 * FROM ['+[NAME]+']' FROM SYS.TABLES ORDER BY [name]


--SELECT TOP 100 * FROM [Archived_Journal Entries_HL2]		 -- ARCHIVED IGNORE. 
--SELECT TOP 100 * FROM [Archived_Journal Entries_HL3]		 -- ARCHIVED IGNORE. 
--SELECT TOP 100 * FROM [Archived_staging_Journal Entrie]		 -- ARCHIVED IGNORE. 
--SELECT TOP 100 * FROM [Archived_staging_Journal Entries_HL2] -- ARCHIVED IGNORE. 
--SELECT TOP 100 * FROM [Archived_staging_Journal_Entries_HL3] -- ARCHIVED IGNORE. 
SELECT TOP 100 * FROM [Change Log Entries till 20240531_HL2]
SELECT TOP 100 * FROM [Change Log Entries till 20240531_HL3]
SELECT TOP 100 * FROM [Chart of Accounts_HL2]
SELECT TOP 100 * FROM [Chart of Accounts_HL3]
SELECT TOP 100 * FROM [Detail JE updated_HL2]
SELECT TOP 100 * FROM [Detail JE updated_HL3]
SELECT TOP 100 * FROM [HL2_Trial Balance _20221231]
SELECT TOP 100 * FROM [HL2_Trial Balance _20231231]
SELECT TOP 100 * FROM [HL3_Trial Balance _20221231]
SELECT TOP 100 * FROM [HL3_Trial Balance _20231231]
SELECT TOP 100 * FROM [je_DrCrMatching]
SELECT TOP 100 * FROM [List of Holiday]
SELECT TOP 100 * FROM [out_Benford_Invoice_2]
SELECT TOP 100 * FROM [out_Benford_Payment_1]
SELECT TOP 100 * FROM [out_Benford_Payment_2]
SELECT TOP 100 * FROM [Payment List HL2]
SELECT TOP 100 * FROM [Payment List HL3]
SELECT TOP 100 * FROM [Payment transactions_HL2]
SELECT TOP 100 * FROM [Payment transactions_HL3]
SELECT TOP 100 * FROM [Pmt_Only]
SELECT TOP 100 * FROM [refBenfordProbability]
SELECT TOP 100 * FROM [staging_ChangeLog_All]
SELECT TOP 100 * FROM [Staging_ChangeLog_HL2]
SELECT TOP 100 * FROM [Staging_ChangeLog_HL3]
SELECT TOP 100 * FROM [staging_Chart_of_Accounts_HL2]
SELECT TOP 100 * FROM [staging_Chart_of_Accounts_HL3]
SELECT TOP 100 * FROM [staging_COA_All]
SELECT TOP 100 * FROM [staging_JE_header]
SELECT TOP 100 * FROM [staging_JE_updated_All]
SELECT TOP 100 * FROM [staging_JE_updated_HL2]
SELECT TOP 100 * FROM [staging_JE_updated_HL3]
SELECT TOP 100 * FROM [Staging_Payment List All]
SELECT TOP 100 * FROM [Staging_Payment List HL2]
SELECT TOP 100 * FROM [Staging_Payment List HL3]
SELECT TOP 100 * FROM [staging_Payment transactions_All]
SELECT TOP 100 * FROM [staging_Payment transactions_HL2]
SELECT TOP 100 * FROM [staging_Payment transactions_HL3]
SELECT TOP 100 * FROM [staging_payment_invoice_cm_refund]
SELECT TOP 100 * FROM [Staging_Trial Balance_HL2_2024]
SELECT TOP 100 * FROM [Staging_Trial Balance_HL3_2024]
SELECT TOP 100 * FROM [staging_Vendor Inv. Claim Lines]
SELECT TOP 100 * FROM [staging_Vendor Inv. Claim List]
SELECT TOP 100 * FROM [staging_Vendor Ledger Entries All]
SELECT TOP 100 * FROM [staging_Vendor Ledger Entries HL2]
SELECT TOP 100 * FROM [staging_Vendor Ledger Entries HL3]
SELECT TOP 100 * FROM [staging_Vendor Master_All]
SELECT TOP 100 * FROM [staging_Vendor Master_HL2]
SELECT TOP 100 * FROM [staging_Vendor Master_HL3]
SELECT TOP 100 * FROM [staging_Vendor_M_Quick_Access]
SELECT TOP 100 * FROM [staging_Vendors All]
SELECT TOP 100 * FROM [staging_Vendors HL2]
SELECT TOP 100 * FROM [staging_Vendors HL3]
SELECT TOP 100 * FROM [Vendor Inv. Claim Lines]
SELECT TOP 100 * FROM [Vendor Inv. Claim List]
SELECT TOP 100 * FROM [Vendor Ledger Entries HL2]
SELECT TOP 100 * FROM [Vendor Ledger Entries HL3]
SELECT TOP 100 * FROM [Vendor Master_HL2]
SELECT TOP 100 * FROM [Vendor Master_HL3]
SELECT TOP 100 * FROM [Vendors HL2]
SELECT TOP 100 * FROM [Vendors HL3]


--