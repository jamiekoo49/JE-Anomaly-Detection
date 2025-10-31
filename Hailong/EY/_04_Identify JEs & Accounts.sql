USE [test_enyu]


--==========================
-- BASE JE INFO 
--==========================
DROP TABLE IF EXISTS [stg_JE_base_info]
SELECT 
	[CompanyName]
	,[PostingDate_GLEntry]
	,[DocumentNo_GLEntry]
	,[EntryNo_GLEntry]
	,[No_GLAcc]
	,[Name_GLAcc]
	,[Description_GLEntry]
	,CASE WHEN [DebitAmount_GLEntry]<>0 THEN 'Dr' 
		WHEN [CreditAmount_GLEntry]<>0 THEN 'Cr' 
		WHEN [DebitAmount_GLEntry]=0 AND [CreditAmount_GLEntry]=0 THEN 'Zero' 
		END AS [Dr or Cr]
	,[DebitAmount_GLEntry]
	,[CreditAmount_GLEntry]
	,[NO_OF_JE_LINES] 
INTO [stg_JE_base_info]
FROM [refHL_staging_JE_updated_All] 
ORDER BY [CompanyName],[DocumentNo_GLEntry]

	/*
	----- CHECK FOR ANY ENTRIES WITH BOTH DB & CR VALUE, OR DB 0 & CR 0. 
	SELECT * FROM [refHL_staging_JE_updated_All] WHERE [DebitAmount_GLEntry]<>0 AND [CreditAmount_GLEntry]<>0 -- 0 --> BOTH DB & CR
	SELECT * FROM [refHL_staging_JE_updated_All] WHERE [DebitAmount_GLEntry]=0 AND [CreditAmount_GLEntry]=0 -- 714 --> DB 0 & CR 0 

	----- VIEW FULL SET OF ENTRIES FOR THE ENTIRE JE, FOR THOSE WITH NO AMOUNT 
	SELECT B.* FROM (
		SELECT DISTINCT [CompanyName],[DocumentNo_GLEntry] FROM [refHL_staging_JE_updated_All] WHERE [DebitAmount_GLEntry]=0 AND [CreditAmount_GLEntry]=0 -- 714
	) A LEFT JOIN (
		SELECT [CompanyName],[PostingDate_GLEntry],[DocumentNo_GLEntry],[EntryNo_GLEntry],[No_GLAcc],[Name_GLAcc],[Description_GLEntry],[DebitAmount_GLEntry],[CreditAmount_GLEntry],[NO_OF_JE_LINES] FROM [refHL_staging_JE_updated_All]
	) B ON A.[CompanyName] = B.[CompanyName]
		AND A.[DocumentNo_GLEntry] = B.[DocumentNo_GLEntry]
	ORDER BY B.[CompanyName],B.[DocumentNo_GLEntry]
	*/ 


--==========================
-- CHART OF ACCOUNTS 
--==========================
/*
----- CHECK IF ACCOUNT NO FOR BOTH ENTITIES ARE THE SAME: Conclusion, same. 
SELECT A.[No],A.[Name],B.[No],B.[Name] FROM (
	SELECT * FROM [refHL_staging_COA_All] WHERE [Company_Name]='hailong2'
) A LEFT JOIN (
	SELECT * FROM [refHL_staging_COA_All] WHERE [Company_Name]='hailong3'
) B ON A.[No] = B.[No] WHERE A.[Name] <> B.[Name]
*/ 


----- TOTAL 272 DISTINCT ACCOUNTS 
--SELECT DISTINCT [NO] FROM [refHL_staging_COA_All] -- 272


----- GET LIST OF ALL ACCOUNTS 
DROP TABLE IF EXISTS [stg_COA_accounts]
SELECT 
	ISNULL(A.[No],B.[No]) AS [No]
	,ISNULL(A.[Name],B.[Name]) AS [Name]
	,ISNULL(A.[Income_Balance],B.[Income_Balance]) AS [Income_Balance]
	,ISNULL(A.[Account_Category],B.[Account_Category]) AS [Account_Category]
	,ISNULL(A.[Account_Subcategory],B.[Account_Subcategory]) AS [Account_Subcategory]
	,ISNULL(A.[Account_Type],B.[Account_Type]) AS [Account_Type]
INTO [stg_COA_accounts]
FROM (
	SELECT DISTINCT 
		[No]
		,[Name]
		,[Income_Balance]
		,[Account_Category]
		,[Account_Subcategory]
		,[Account_Type] 
	FROM [refHL_staging_COA_All] 
	WHERE [Company_Name]='hailong2'
) A FULL OUTER JOIN (
	SELECT DISTINCT 
		[No]
		,[Name]
		,[Income_Balance]
		,[Account_Category]
		,[Account_Subcategory]
		,[Account_Type] 
	FROM [refHL_staging_COA_All] 
	WHERE [Company_Name]='hailong3'
) B ON A.[No] = B.[No]


SELECT A.[No],A.[Name],B.[No],B.[Name] FROM (
	SELECT * FROM [refHL_staging_COA_All] WHERE [Company_Name]='hailong2'
) A LEFT JOIN (
	SELECT * FROM [refHL_staging_COA_All] WHERE [Company_Name]='hailong3'
) B ON A.[No] = B.[No] WHERE A.[Name] <> B.[Name]


----- GET LIST OF ALL ACCOUNTS + NO. OF TXNS
DROP TABLE IF EXISTS [stg_COA_accounts_stats]
SELECT *
INTO [stg_COA_accounts_stats]
FROM (
	SELECT  * FROM [stg_COA_accounts] -- 272
) A LEFT JOIN (
	SELECT 
		--[CompanyName]
		[No_GLAcc]
		,COUNT(*) AS [No. of Entries]
		,SUM(IIF([Dr or Cr]='Dr',1,0)) AS [No. of Dr Entries]
		,SUM(IIF([Dr or Cr]='Cr',1,0)) AS [No. of Cr Entries]
		,SUM(IIF([CompanyName]='Hailong2',1,0)) AS [No. of Entries (HL2)]
		,SUM(IIF([CompanyName]='Hailong2' AND [Dr or Cr]='Dr',1,0)) AS [No. of Dr Entries (HL2)]
		,SUM(IIF([CompanyName]='Hailong2' AND [Dr or Cr]='Cr',1,0)) AS [No. of Cr Entries (HL2)]
		,SUM(IIF([CompanyName]='Hailong3',1,0)) AS [No. of Entries (HL3)]
		,SUM(IIF([CompanyName]='Hailong3' AND [Dr or Cr]='Dr',1,0)) AS [No. of Dr Entries (HL3)]
		,SUM(IIF([CompanyName]='Hailong3' AND [Dr or Cr]='Cr',1,0)) AS [No. of Cr Entries (HL3)]
	FROM [stg_JE_base_info] 
	GROUP BY [No_GLAcc]
) B ON A.[No] = B.[No_GLAcc] 
	--AND A.[Company_Name] = B.[CompanyName]
--WHERE B.[No_GLAcc] IS NOT NULL -- 197


--==========================
-- BASE JE INFO 
--==========================
DROP TABLE IF EXISTS [stg_ClusterAccs_01_JEWithAccInfo]
SELECT
	A.*
	,B.[Name]
	,B.[Account_Category]
	,B.[Account_Subcategory]
INTO [stg_ClusterAccs_01_JEWithAccInfo]
FROM [stg_JE_base_info] A
LEFT JOIN [stg_COA_accounts] B
ON A.[No_GLAcc] = B.[No]

--==========================
-- CREATE FEATURES 
--==========================

SELECT * FROM [stg_JE_base_info] 
SELECT * FROM [stg_ClusterAccs_01_JEWithAccInfo]
SELECT * FROM [stg_COA_accounts] 
SELECT * FROM [stg_COA_accounts_stats] WHERE [No. of Entries] IS NOT NULL ORDER BY 1
SELECT * FROM [stg_ClusterAccs_02_JEWithAccFeatures]


SELECT * FROM [stg_JE_base_info] ORDER BY CompanyName,DocumentNo_GLEntry, EntryNo_GLEntry
SELECT distinct No_GLAcc,Name_GLAcc FROM [stg_JE_base_info] ORDER BY No_GLAcc
PostingDate_GLEntry
Description_GLEntry
NO_OF_JE_LINES
