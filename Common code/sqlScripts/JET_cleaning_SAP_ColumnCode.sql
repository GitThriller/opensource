----------------------------------------------------------------
--SAMPLE SAP JOURNAL ENTRIES DATA CLEANSING SCRIPT (SINGLE ENTITY or *MULTIPLE ENTITIES)
--Created by: Wei Wu - 14/11/2019

--***BKPF(Header) table includes these columns***
--Company Code: BUKRS or COMPANY_CODE Varchar(8)
--Journal ID: BLART or DOCUMENT_TYPE Varchar(4)
--Date effective: BUDAT or POSTING_DATE Varchar(16)
--Date posted: CPUDT or ENTRY_DATE Varchar(16)
--Posting user: USNAM or USER_ID Varchar(24)
--Journal description: BKTXT or DESCRIPTION Varchar(50)

--***BSEG(Detail) table includes these columns*** 
--Company Code: BUKRS or COMPANY_CODE Varchar(8)
--Journal ID: BELNR or DOCUMENT_NUMBER Varchar(20)
--Debit/credit indicator: SHKZG or DEBIT_CREDIT_INDICATOR Varchar(2)
--Amount: DMBTR or GL_AMOUNT_LOCAL Varchar(30)
--Amount-Foreign currency: WRBTR or AMOUNT  Varchar(30)
--Journal description: SGTXT or DESCRIPTION2 Varchar(100)
--GL account: HKONT or GL_ACCOUNT_NUMBER Varchar(20)

--We need to combine the BKPF and BSEG file to get the full journal entry listing (JOIN on Company Code and Journal ID) 
----------------------------------------------------------------

----------------------------------------------------------------
--VALIDATION (pre-cleansing)
----------------------------------------------------------------
--Row count
SELECT COUNT(*) FROM [XXXX].RAW_SAMPLE_BKPF_XX_XXXXXXXX AS BKPF --Row count (XXXX rows) for BKPF(Header) table
SELECT COUNT(*) FROM [XXXX].RAW_SAMPLE_BSEG_XX_XXXXXXXX AS BSEG --Row count (XXXX rows) for BSEG(Detail) table

--Netting to zero (Amount & Foreign currency amount) BSEG table
SELECT [SHKZG or Column XX], SUM(CAST([DMBTR or Column XX] AS MONEY)) FROM [XXXX].RAW_SAMPLE_BSEG_XX_XXXXXXXX AS BSEG
GROUP BY [SHKZG or Column XX]
	--S is debit (+ve)
	--H is credit (-ve)
	
--Dates within period (Date effective) BKPF table
SELECT DISTINCT CONVERT (DATE, REPLACE([BUDAT or Column XX],'.','-'),103)
FROM [XXXX].RAW_SAMPLE_BKPF_XX_XXXXXXXX AS BKPF
WHERE CONVERT (DATE, REPLACE([BUDAT or Column XX],'.','-'),103) NOT BETWEEN '20XX-XX-XX' AND '20XX-XX-XX' --To check for journals date effective not within testing period

----------------------------------------------------------------
--CREATING EXP table which combines BSEG and BKPF
----------------------------------------------------------------

IF OBJECT_ID ('[XXXX].EXP_SAMPLE') IS NOT NULL
DROP TABLE [XXXX].EXP_SAMPLE

SELECT 
LTRIM(RTRIM(BSEG.[BUKRS or Column XX]))  AS [Company Code], --(Optional step) This column is only required when the JET data is for multiple entities

LTRIM(RTRIM(BSEG.[BELNR or Column XX])) AS [Journal ID],

LTRIM(RTRIM(BSEG.[BUZEI or Column XX])) AS [Journal line number],

CASE WHEN BSEG.[SHKZG or Column XX] = 'S' THEN CAST(BSEG.[DMBTR or Column XX] AS MONEY)
ELSE -1*CAST(BSEG.[DMBTR or Column XX] AS MONEY)
END AS [Amount], --To change amount signs (S is debit; H is credit)

CASE WHEN BSEG.[SHKZG or Column XX] = 'S' THEN CAST(BSEG.[WRBTR or Column XX] AS MONEY)
ELSE -1*CAST(BSEG.[WRBTR or Column XX] AS MONEY)
END AS [Foreign currency amount], --(Optional step) This column is only required when there is foreign currency amount

CONCAT(LTRIM(RTRIM([BSEG].[SGTXT or Column XX])),' ',LTRIM(RTRIM([BKPF].[BKTXT or Column XX]))) AS [Journal description], --To concatenate descriptions from BSEG and BKPF

LTRIM(RTRIM(BSEG.[HKONT or Column XX])) AS [GL account],

LTRIM(RTRIM(BKPF.[BLART or Column XX])) AS [Document Type],

CONVERT(DATE,BKPF.[BUDAT or Column XX],103) AS [Date effective],

CONVERT(DATE,BKPF.[CPUDT or Column XX],103) AS [Date posted],

LTRIM(RTRIM(BKPF.[USNAM or Column XX])) AS [Posting User],

INTO [XXXX].EXP_SAMPLE
FROM [XXXX].RAW_SAMPLE_BSEG_XX_XXXXXXXX AS BSEG
LEFT JOIN [XXXX].RAW_SAMPLE_BKPF_XX_XXXXXXXX AS BKPF
ON BSEG.[BUKRS or Column XX] = BKPF.[BUKRS or Column XX] --(Optional step) To JOIN on same company code
AND BSEG.[BELNR or Column XX] = BKPF.[BELNR or Column XX] --To JOIN on same journal ID

----------------------------------------------------------------
--VALIDATION (post-cleansing)
----------------------------------------------------------------
--Row count
SELECT COUNT(*) FROM [XXXX].EXP_SAMPLE

--Netting to zero
SELECT [Journal ID], SUM([Amount]) FROM [XXXX].EXP_SAMPLE
GROUP BY [Journal ID]
HAVING SUM([Amount]) <> 0

--Dates within period
SELECT DISTINCT [Date effective] FROM [XXXX].EXP_SAMPLE
WHERE [Date effective] NOT BETWEEN '20XX-XX-XX' AND '20XX-XX-XX'

----------------------------------------------------------------
--SAVE CLEAN DATA
----------------------------------------------------------------
--Journal lines
SELECT * FROM [XXXX].EXP_SAMPLE
WHERE [Company Code] ='xx' --(Optional step) 
ORDER BY [Journal line number] ASC

--Document types
SELECT DISTINCT [Document Type],
		'0' AS [Is standard document TYPE]
		COUNT(DISTINCT [Journal ID]) AS [Number of Journal IDs],
		COUNT([Journal line number]) AS [Number of Journal Lines],
		SUM(CONVERT(MONEY, Amount)) AS [Sum of Amount]
FROM [XXXX].EXP_SAMPLE
GROUP BY [Document Type]
ORDER BY [Document Type] ASC

--Posting users
SELECT DISTINCT [Posting user],
		'0' AS [Is system entry],
		'0' AS [User Of Interest]
		COUNT(DISTINCT [Journal ID]) AS [Number of Journal IDs],
		COUNT([Journal line number]) AS [Number of Journal Lines],
		SUM(CONVERT(MONEY, Amount)) AS [Sum of Amount]
FROM [XXXX].EXP_SAMPLE
GROUP BY [Posting user]
ORDER BY [Posting user] ASC
----------------------------------------------------------------
--END OF SCRIPT
----------------------------------------------------------------
