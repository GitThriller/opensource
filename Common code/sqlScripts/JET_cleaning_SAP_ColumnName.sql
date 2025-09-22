----------------------------------------------------------------
--SAMPLE SAP JOURNAL ENTRIES DATA CLEANSING SCRIPT (SINGLE ENTITY or *MULTIPLE ENTITIES)
--Created by: Wei Wu - 14/11/2019

--***BKPF(Header) table includes these columns***
--Company Code: BUKRS or COMPANY_CODE Varchar(8)
--Journal ID: BELNR or DOCUMENT_NUMBER Varchar(20)
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
SELECT [DEBIT_CREDIT_INDICATOR Varchar(2)], SUM(CAST([GL_AMOUNT_LOCAL Varchar(30)] AS MONEY)) FROM [XXXX].RAW_SAMPLE_BSEG_XX_XXXXXXXX AS BSEG
GROUP BY [DEBIT_CREDIT_INDICATOR Varchar(2)]
	--S is debit (+ve)
	--H is credit (-ve)
	
--Dates within period (Date effective) BKPF table
SELECT DISTINCT CONVERT (DATE, REPLACE([POSTING_DATE Varchar(16)],'.','-'),103)
FROM [XXXX].RAW_SAMPLE_BKPF_XX_XXXXXXXX AS BKPF
WHERE CONVERT (DATE, REPLACE([POSTING_DATE Varchar(16)],'.','-'),103) NOT BETWEEN '20XX-XX-XX' AND '20XX-XX-XX' --To check for journals date effective not within testing period

----------------------------------------------------------------
--CREATING EXP table which combines BSEG and BKPF
----------------------------------------------------------------

IF OBJECT_ID ('[XXXX].EXP_SAMPLE') IS NOT NULL
DROP TABLE [XXXX].EXP_SAMPLE

SELECT 
LTRIM(RTRIM(BSEG.[COMPANY_CODE Varchar(8)]))  AS [Company Code], --(Optional step) This column is only required when the JET data is for multiple entities

LTRIM(RTRIM(BSEG.[DOCUMENT_NUMBER Varchar(20)])) AS [Journal ID],

LTRIM(RTRIM(BSEG.[LINE_ITEM Varchar(6)])) AS [Journal line number],

CASE WHEN BSEG.[DEBIT_CREDIT_INDICATOR Varchar(2)] = 'S' THEN CAST(BSEG.[GL_AMOUNT_LOCAL Varchar(30)] AS MONEY)
ELSE -1*CAST(BSEG.[GL_AMOUNT_LOCAL Varchar(30)] AS MONEY)
END AS [Amount], --To change amount signs (S is debit; H is credit)

CASE WHEN BSEG.[DEBIT_CREDIT_INDICATOR Varchar(2)] = 'S' THEN CAST(BSEG.[AMOUNT  Varchar(30)] AS MONEY)
ELSE -1*CAST(BSEG.[AMOUNT  Varchar(30)] AS MONEY)
END AS [Foreign currency amount], --(Optional step) This column is only required when there is foreign currency amount

CONCAT(LTRIM(RTRIM([BSEG].[DESCRIPTION2 Varchar(100)])),' ',LTRIM(RTRIM([BKPF].[DESCRIPTION Varchar(50)]))) AS [Journal description], --To concatenate descriptions from BSEG and BKPF

LTRIM(RTRIM(BSEG.[GL_ACCOUNT_NUMBER Varchar(20)])) AS [GL account],

LTRIM(RTRIM(BKPF.[DOCUMENT_TYPE Varchar(4)])) AS [Document Type],

CONVERT(DATE,BKPF.[POSTING_DATE Varchar(16)],103) AS [Date effective],

CONVERT(DATE,BKPF.[ENTRY_DATE Varchar(16)],103) AS [Date posted],

LTRIM(RTRIM(BKPF.[USER_ID Varchar(24)])) AS [Posting User],

INTO [XXXX].EXP_SAMPLE
FROM [XXXX].RAW_SAMPLE_BSEG_XX_XXXXXXXX AS BSEG
LEFT JOIN [XXXX].RAW_SAMPLE_BKPF_XX_XXXXXXXX AS BKPF
ON BSEG.[COMPANY_CODE Varchar(8)] = BKPF.[COMPANY_CODE Varchar(8)] --(Optional step) To JOIN on same company code
AND BSEG.[DOCUMENT_NUMBER Varchar(20)] = BKPF.[DOCUMENT_NUMBER Varchar(20)] --To JOIN on same journal ID

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
FROM [XXXX].EXP_SAMPLE

--Posting users
SELECT DISTINCT [Posting user],
'0' AS [Is system entry],
'0' AS [User Of Interest]
FROM [XXXX].EXP_SAMPLE

----------------------------------------------------------------
--END OF SCRIPT
----------------------------------------------------------------
