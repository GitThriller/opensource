USE DT_DIYA_PACKAGE_DATA_CLEANSING_2018
GO

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Cleaning Script Summary --

-- Script Version: V1_EL	created on 01/05/2020
--				   V2_EL	modified on 07/05/2020
-- Ticket Number: XXXX
-- Testing Type: Journal Entry Test (JET)
-- System Type: Xero
-- Engagement Code: XXXXX-XXXX
-- Client Name: XXXXXX
-- Entity Name: XXX
-- Input: RAW table
-- Output: 
	-- Cleaned EXP table (EXP1, EXP2 if split table requested)
	-- Document type
	-- Posting user
-- Script Sections: Pre Validation, Create Tables, Post Validation
-- Validation check items:
	-- row count
	-- date range
	-- Netting to Zero
	-- Netting to Zero by Each Journal
	-- Uniqueness
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- Pre Validation --
------------------------------------------------------------------------------------
-- rowcount RAW table
SELECT COUNT(*) FROM [0000].[RAW_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [alias] 


-- preview RAW table
SELECT * FROM [0000].[RAW_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [alias]
-- basically it's in the format of 5 columns
-- [DTT_ID], [Column 0], [Column 1], [Column 2] and [DTT_Filename]

-- check if RAW table netting to zero
SELECT SUM(CAST([alias].[Column 1] AS MONEY) - CAST([alias].[Column 2] AS MONEY)) 
FROM  [0000].[RAW_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [alias] 
WHERE (ISNUMERIC([alias].[Column 1]) + ISNUMERIC([alias].[Column 2]) = 1 )
			AND [alias].[Column 0] <> ''


------------------------------------------------------------------------------------
-- Creat Tables --
------------------------------------------------------------------------------------
-- drop temp table if exists
IF OBJECT_ID('tempdb..#temp_entityname','U') IS NOT NULL
	DROP TABLE #temp_entityname

-- create temp table to fill down details
SELECT [alias].DTT_ID
	   ,LEAD([alias].DTT_ID) OVER (ORDER BY [alias].DTT_ID) AS [YOYOYO]
	   ,[alias].[Column 2] AS [Date effective]
	   ,SUBSTRING([alias].[Column 0],4,CHARINDEX(' ',[alias].[Column 0],4) - 4) AS [Journal ID]
	   ,LTRIM(RTRIM([alias].[Column 0])) AS [Journal description]			  
	   ,SUBSTRING(SUBSTRING([alias].[Column 0],CHARINDEX('posted',[alias].[Column 0])+10,100)
				  ,1
				  ,CHARINDEX(' on',SUBSTRING([alias].[Column 0],CHARINDEX('posted',[alias].[Column 0])+10,100))-1)
				 AS [Posting user]
	   ,SUBSTRING(SUBSTRING([alias].[Column 0],CHARINDEX('posted by',[alias].[Column 0])+10, 100)
				  ,CHARINDEX(' on ',SUBSTRING([alias].[Column 0],CHARINDEX('posted by',[alias].[Column 0])+10, 100))+4
				  ,CHARINDEX(')',SUBSTRING([alias].[Column 0],CHARINDEX('posted by',[alias].[Column 0])+10, 100))
						-(CHARINDEX(' on ',SUBSTRING([alias].[Column 0],CHARINDEX('posted by',[alias].[Column 0])+10, 100))+4))
			     AS [Date posted]
	   ,CASE WHEN [alias].[Column 0] LIKE '%(Manual Journal%' THEN 'manual'
		     ELSE 'auto'
		END AS [Document type]
INTO #temp_entityname
FROM [0000].[RAW_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [alias] 
WHERE [alias].[Column 0] LIKE 'ID %'


-- preview
SELECT * FROM #temp_entityname AS [tempalias]

-- drop EXP table if exists
IF OBJECT_ID('[0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]','U') IS NOT NULL
	DROP TABLE [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]

-- create EXP table
SELECT 
		 CASE WHEN ISNUMERIC([Column 1]) + ISNUMERIC([Column 2]) = 1
		      THEN CAST([alias].[Column 1] AS MONEY) - CAST([alias].[Column 2] AS MONEY) 
		 END AS [Amount]
		,CAST([tempalias].[Date effective] AS DATE) AS [Date effective]
		,CAST([tempalias].[Date posted] AS DATE) AS [Date posted]
		,[alias].DTT_ID AS [Journal line number]
		,LTRIM(RTRIM([tempalias].[Journal ID])) AS [Journal ID]
		,[tempalias].[Journal description] + ' ' + LTRIM(RTRIM([alias].[Column 0])) AS [Journal description]
		,CASE WHEN LTRIM(RTRIM([alias].[Column 0])) IN ('')
		      THEN [alias].[Column 0]
		      ELSE REPLACE(RIGHT([alias].[Column 0],CHARINDEX('(',REVERSE([alias].[Column 0]))-1),')','')
		 END AS [GL account]
		,LTRIM(RTRIM([tempalias].[Document type])) AS [Document type]
		,LTRIM(RTRIM([tempalias].[Posting user])) AS [Posting user]
INTO [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]
FROM [0000].[RAW_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [alias]
		LEFT JOIN #temp_entityname AS [tempalias]
			ON [alias].DTT_ID BETWEEN [tempalias].DTT_ID AND ISNULL([tempalias].YOYOYO,99999999)
WHERE [alias].[Column 0] NOT LIKE 'ID %'
		AND [alias].[Column 0] NOT LIKE 'From %'
		AND [alias].[Column 0] NOT IN (''
								    )		



-- Create 2 split tables as requested

-- split 1 for '2018-07-01' AND '2019-06-30'
IF OBJECT_ID('[6310].EXP_IFHC_JUL_FEB_20200420_EL_P1','U') IS NOT NULL
	DROP TABLE [6310].EXP_IFHC_JUL_FEB_20200420_EL_P1

SELECT * 
INTO [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS] AS [exp_alias]
WHERE [exp_alias].[Date effective] BETWEEN '2018-07-01' AND '2019-06-30'
-- (316 rows affected)

-- split 2 for '2019-07-01' AND '2020-02-28'
IF OBJECT_ID('[0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2','U') IS NOT NULL
	DROP TABLE [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2

SELECT * 
INTO [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]
WHERE [exp_alias].[Date effective] BETWEEN '2019-07-01' AND '2020-02-28'
-- (202 rows affected)

------------------------------------------------------------------------------------
-- Post Validation for Financial Period Between '2018-07-01' AND '2019-06-30' --
------------------------------------------------------------------------------------
-- rowcount
SELECT COUNT(*) FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
-- 316, as expected, as removing empty value and table titles 

-- preview
SELECT * FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]

-- date range
SELECT MIN([exp_alias_p1].[Date effective]), MAX([exp_alias_p1].[Date effective]) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
-- 2018-07-02 to 2019-06-30, within requested financial period

-- check if netting to zero
SELECT SUM(Amount) FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
-- 0

-- check if netting to zero by journal
SELECT [exp_alias_p1].[Journal ID]
	   ,SUM([exp_alias_p1].Amount) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
GROUP BY [exp_alias_p1].[Journal ID]
HAVING ABS(SUM([exp_alias_p1].Amount)) > 0
-- 0

-- check uniqueness
SELECT [exp_alias_p1].[Journal ID]
       ,[exp_alias_p1].[Journal line number]
	   ,COUNT(*) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
GROUP BY [exp_alias_p1].[Journal ID], [exp_alias_p1].[Journal line number]
HAVING COUNT(*) > 1
-- unique

-- Document type
SELECT [exp_alias_p1].[Document type]
	   ,'0' AS [Is standard document type]
	   ,COUNT([exp_alias_p1].[Journal ID]) AS [Number of Journal IDs]
	   ,COUNT([exp_alias_p1].[Journal line number]) AS [Number of Journal Lines]
	   ,SUM(Amount) AS [Sum of Amount]
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
GROUP BY [Document Type]
ORDER BY [Document Type] ASC

--Posting user
SELECT [exp_alias_p1].[Posting user]
	   ,'0' AS [Is system entry]
	   ,'0' AS [User Of Interest]
	   ,COUNT([exp_alias_p1].[Journal ID]) AS [Number of Journal IDs]
	   ,COUNT([exp_alias_p1].[Journal line number]) AS [Number of Journal Lines]
	   ,SUM(Amount) AS [Sum of Amount]
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P1 AS [exp_alias_p1]
GROUP BY [Posting user]
ORDER BY [Posting user] ASC

------------------------------------------------------------------------------------
-- Post Validation for Financial Period Between '2019-07-01' AND '2020-02-28' --
------------------------------------------------------------------------------------
-- rowcount
SELECT COUNT(*) FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
-- 202, as expected, as removing empty value and table titles 

-- preview
SELECT * FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]

-- date range
SELECT MIN([exp_alias_p2].[Date effective]), MAX([exp_alias_p2].[Date effective]) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
-- 2019-07-01 to 2020-02-28, within requested financial period

-- check if netting to zero
SELECT SUM(Amount) FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
-- 0

-- check if netting to zero by journal
SELECT [exp_alias_p2].[Journal ID]
	   ,SUM([exp_alias_p2].Amount) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
GROUP BY [exp_alias_p2].[Journal ID]
HAVING ABS(SUM([exp_alias_p2].Amount)) > 0
-- 0

-- check uniqueness
SELECT [exp_alias_p2].[Journal ID]
       ,[exp_alias_p2].[Journal line number]
	   ,COUNT(*) 
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
GROUP BY [exp_alias_p2].[Journal ID], [exp_alias_p2].[Journal line number]
HAVING COUNT(*) > 1
-- unique

-- Document type
SELECT [exp_alias_p2].[Document type]
	   ,'0' AS [Is standard document type]
	   ,COUNT([exp_alias_p2].[Journal ID]) AS [Number of Journal IDs]
	   ,COUNT([exp_alias_p2].[Journal line number]) AS [Number of Journal Lines]
	   ,SUM(Amount) AS [Sum of Amount]
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
GROUP BY [Document Type]
ORDER BY [Document Type] ASC

--Posting user
SELECT [exp_alias_p2].[Posting user]
	   ,'0' AS [Is system entry]
	   ,'0' AS [User Of Interest]
	   ,COUNT([exp_alias_p2].[Journal ID]) AS [Number of Journal IDs]
	   ,COUNT([exp_alias_p2].[Journal line number]) AS [Number of Journal Lines]
	   ,SUM(Amount) AS [Sum of Amount]
FROM [0000].[EXP_ENTITY-NAME_UPLOADING-DATE_YOUR-NAME-INITIALS]_P2 AS [exp_alias_p2]
GROUP BY [Posting user]
ORDER BY [Posting user] ASC