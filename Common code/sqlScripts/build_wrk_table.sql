----------------------------------------------------------------
--Code to generate CREATE TABLE and INSERT INTO statements
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
              ELSE 'VARCHAR(255)' END
--SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = ''



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



--------------------------------------------------------
-- Code to generate MAX LEN statement
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