USE [test_enyu]

SELECT 'SELECT TOP 100 * FROM ['+[NAME]+']' FROM SYS.tables

--==========================
-- CHART OF ACCOUNTS 
--==========================
SELECT DISTINCT [Company_Name],[Account_Category],[Account_Subcategory] FROM [refHL_staging_COA_All] WHERE [Account_Subcategory] IS NOT NULL ORDER BY 1,2,3
SELECT * FROM [refHL_staging_COA_All] ORDER BY [CompanyName],[NO]--,[Account_Category],[Account_Subcategory],[Account_Type] -- 516 
SELECT TOP 100 * FROM [refHL_staging_COA_HL2]
SELECT TOP 100 * FROM [refHL_staging_COA_HL3]

--==========================
-- JE 
--==========================
SELECT [CompanyName], [No_GLAcc], [Description_GLEntry], [PostingDate_GLEntry], [DebitAmount_GLEntry], [CreditAmount_GLEntry] FROM [refHL_staging_JE_updated_All] ORDER BY 1,2
SELECT [CompanyName],[PostingDate_GLEntry],[DocumentNo_GLEntry],[EntryNo_GLEntry],[No_GLAcc],[Name_GLAcc],[Description_GLEntry],[DebitAmount_GLEntry],[CreditAmount_GLEntry],[NO_OF_JE_LINES] FROM [refHL_staging_JE_updated_All] ORDER BY [CompanyName],[DocumentNo_GLEntry]

SELECT TOP 100 * FROM [refHL_staging_JE_updated_All] 
SELECT TOP 100 * FROM [refHL_staging_JE_updated_HL2]
SELECT TOP 100 * FROM [refHL_staging_JE_updated_HL3]

--==========================
-- Payment listing
--==========================
SELECT TOP 100 * FROM [refHL_staging_Payment_List_All]
SELECT TOP 100 * FROM [refHL_staging_Payment_List_HL2]
SELECT TOP 100 * FROM [refHL_staging_Payment_List_HL3]

--==========================
-- Trial balance
--==========================
SELECT TOP 100 * FROM [refHL_staging_Trial_Balance_HL2_2024]
SELECT TOP 100 * FROM [refHL_staging_Trial_Balance_HL3_2024]

--==========================
-- Vendor
--==========================
SELECT TOP 100 * FROM [refHL_staging_Vendors_All]
SELECT TOP 100 * FROM [refHL_staging_Vendors_HL2]
SELECT TOP 100 * FROM [refHL_staging_Vendors_HL3]
