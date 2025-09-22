--------------------------------------------------------
-- Extract db info
--------------------------------------------------------
EXEC sp_databases
EXEC sp_spaceused

SELECT @@VERSION

SELECT name, compatibility_level
FROM sys.databases

--ALTER DATABASE AA SET COMPATIBILITY_LEVEL = 150

sys.objects, sys.schemas, sys.columns

--------------------------------------------------------
-- Create temp db size table
--------------------------------------------------------
IF OBJECT_ID('tempdb..#DB_SIZE','U') IS NOT NULL
	DROP TABLE #DB_SIZE

SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
INTO #DB_SIZE
FROM 
    sys.tables t

INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id

INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id

INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id

LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id

WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    TotalSpaceMB DESC, t.Name


--------------------------------------------------------
-- Extract tables
--------------------------------------------------------
SELECT 
	DS.SchemaName
	,DS.TableName
	,DS.UsedSpaceMB
FROM #DB_SIZE AS DS
WHERE DS.TableName LIKE '%RAW%'
AND LEN(TRY_CAST(DS.SchemaName AS BIGINT))>4
ORDER BY DS.UsedSpaceKB DESC, SUBSTRING(DS.TableName,4,100) ASC

SELECT 
	DS.SchemaName
	,DS.TableName
	,DS.UsedSpaceMB
FROM #DB_SIZE AS DS
WHERE DS.TableName LIKE '%RAW%'
AND DS.SchemaName='dbo'
AND LEN(TRY_CAST(SUBSTRING(DS.TableName,1,5) AS BIGINT))>4
ORDER BY DS.UsedSpaceKB DESC, SUBSTRING(DS.TableName,4,100) ASC

SELECT 
    * 
FROM #DB_SIZE AS DS
WHERE DS.TableName LIKE '%EXP_%' AND DS.TableName NOT LIKE '%RAW_%'

SELECT DISTINCT 
    DS.SchemaName
FROM #DB_SIZE AS DS
ORDER BY 1

SELECT 
    'drop table ['+T.TABLE_SCHEMA+'].['+T.TABLE_NAME+']' FROM INFORMATION_SCHEMA.TABLES AS T
WHERE T.TABLE_NAME LIKE '%DRV_%' AND T.TABLE_NAME NOT LIKE '%RAW_%'

SELECT 
    'drop table ['+T.TABLE_SCHEMA+'].['+T.TABLE_NAME+']' FROM INFORMATION_SCHEMA.TABLES AS T
WHERE T.TABLE_SCHEMA LIKE '%MYAN_%'
ORDER BY 1

SELECT 
    'drop table ['+T.TABLE_SCHEMA+'].['+T.TABLE_NAME+']' FROM INFORMATION_SCHEMA.TABLES AS T
ORDER BY 1

SELECT 
    'drop PROC ['+T.ROUTINE_SCHEMA+'].['+T.ROUTINE_NAME+']'
FROM INFORMATION_SCHEMA.ROUTINES T
WHERE ROUTINE_TYPE = 'PROCEDURE'