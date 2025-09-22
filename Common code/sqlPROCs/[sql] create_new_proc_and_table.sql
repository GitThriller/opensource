USE xxx
GO

GO
DECLARE @proc_name VARCHAR(255) = 'proc_name'
IF OBJECT_ID(@proc_name) IS NULL
BEGIN
	EXEC('CREATE PROC '+@proc_name+' AS')
END
GO
ALTER PROC proc_name
AS

----------------------------------------------------------------
----------------------------------------------------------------
/*
Update History:
Version 0.1 (YYMMDD): {author} : {Description}
Version 0.2 (YYMMDD): {author} : {Description}

-------------------------------------------------------

Script Purpose:
{Description}

Input Table(s):
SELECT TOP 100 * FROM {input_table}

Output Table(s):
SELECT TOP 100 * FROM {output_table}

*/
----------------------------------------------------------------
----------------------------------------------------------------

-- type 'dbn' to generate current DB name

----------------------------------------------------------------
--Code to generate column names and types for CREATE
----------------------------------------------------------------
SELECT
       CASE WHEN ORDINAL_POSITION = 1 THEN '' ELSE ',' END
       + '[' 
       --+ COLUMN_NAME    -- to get the raw file data field, uncomment Column_Name and comment out the replace statement and case when statement below
       + REPLACE(REPLACE(RTRIM(LTRIM(REPLACE(COLUMN_NAME,' (Key)',''))),' ','_'),'__','_')
       + ']'

       -- INT DATA TYPES                        
       +' '+CASE WHEN COLUMN_NAME IN ('UNID','ItmNo') THEN 'INT'
       -- DATE DATA TYPES   
       WHEN COLUMN_NAME LIKE '%Date%' OR COLUMN_NAME LIKE '%Valid%from%' OR COLUMN_NAME LIKE '%Valid%to%' 
                     OR COLUMN_NAME LIKE '%Start%Date%' OR COLUMN_NAME LIKE '%End%Date%' THEN 'DATE'
       -- FLOAT DATA TYPES   
              WHEN COLUMN_NAME LIKE '%Size%' OR COLUMN_NAME LIKE '%Quantity%' OR COLUMN_NAME LIKE '%Value%'
                     OR COLUMN_NAME LIKE '%Amount%'OR COLUMN_NAME LIKE'%Amt%' THEN 'FLOAT'
              
                     WHEN COLUMN_NAME = 'DTT_ID' THEN 'INT'
              ELSE 'NVARCHAR(255)' END
       --SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = ''

--------------------------------------------------------
-- Code to generate MAX LEN for each column
-------------------------------------------------------- 
SELECT
       CASE WHEN ORDINAL_POSITION = 1 THEN '' ELSE ',' END
--       + 'NULLIF('+ 'ltrim(rtrim([' 
	  + 'MAX(LEN(['
       + COLUMN_NAME    -- to get the raw file data field, uncomment Column_Name and comment out the replace statement and case when statement below
	   + ']))'
--       + '])),'''')' 
+ ' ' + '['+COLUMN_NAME+']'
                    

--SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = ''


--------------------------------------------------------
-- CREATE TABLE WITH CHECK WHERE APPLICABLE
--------------------------------------------------------
IF OBJECT_ID('dbo.xxx','U') IS NOT NULL
	DROP TABLE dbo.xxx

IF OBJECT_ID('tempdb..#xxx','U') IS NOT NULL
	DROP TABLE #xxx


CREATE TABLE dbo.xxx
(
	Employee_ID INT CHECK(LEN(Employee_ID) = 5) NOT NULL
	,Recruiter_ID INT CHECK(LEN(Recruiter_ID) = 5)
	,Transaction_Date DATE CHECK(Transaction_Date BETWEEN '2011-07-01' AND '2012-06-30')
	UNIQUE(Employee_ID,Transaction_Date,Transaction_Type)
)


--------------------------------------------------------
-- INSERT TEMP TABLES USING CTE
--------------------------------------------------------

;WITH 

cte_1 AS 
(

)


,cte_2 AS 
(

)


--------------------------------------------------------
-- INSERT TABLE
--------------------------------------------------------
INSERT INTO	dbo.xxx


----------------------------------------------------------------
--Code to generate SELECT statement
----------------------------------------------------------------
SELECT
       CASE WHEN ORDINAL_POSITION = 1 THEN '' ELSE ',' END
       + 'NULLIF('+ 'LTRIM(RTRIM([' 
       + COLUMN_NAME    -- to get the raw file data field, uncomment Column_Name and comment out the replace statement and case when statement below
       + '])),'''')' + ' ' + '['+COLUMN_NAME+']'
--SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = ''


SELECT 
	
FROM dbo.xxx