-- Create Table which can be used to report order of procedures, dependencies and tables used.
       IF OBJECT_ID('RPT_Job_Steps') IS NOT NULL
             BEGIN
                    DROP TABLE RPT_Job_Steps
             END

       CREATE TABLE RPT_Job_Steps
       (
             [DA Execution Order] INT
             ,[DA Procedure Name] VARCHAR(255)
             ,[Table Type] VARCHAR(255)
             ,[Table Name] VARCHAR(255)
             ,[Number of Rows in Table] VARCHAR(255)
             ,[Procedure Creation Date] DATETIME
             UNIQUE([DA Procedure Name],[Table Name])
       )

       INSERT INTO RPT_Job_Steps

       SELECT DISTINCT 
             CASE
                    WHEN dbo.UDF_NthField(z.name,'_',2) = 'REF' THEN 1
                    WHEN dbo.UDF_NthField(z.name,'_',2) = 'WRK' THEN 2
                    WHEN dbo.UDF_NthField(z.name,'_',2) IN ( 'DRV','STG') THEN 3
                    WHEN dbo.UDF_NthField(z.name,'_',2) IN ( 'EXP', 'MOD') THEN 4
                    ELSE NULL
             END
             ,z.name 
             ,CASE WHEN CHARINDEX(referenced_entity_name,z.name,1) <> 0 THEN 'Output Table' ELSE 'Input Table' END Output_Flag
             ,referenced_entity_name
             ,x.rows
             ,create_date
       FROM sys.objects z
       LEFT JOIN sys.sql_expression_dependencies y
       ON z.object_id = y.referencing_id
       LEFT JOIN 
             (
             --TABLE ROW COUNTS
             SELECT
                    sysobjects.Name
                    , sysindexes.Rows
             FROM sysobjects
             INNER JOIN sysindexes
                    ON sysobjects.id = sysindexes.id
             WHERE type = 'U'
             AND sysindexes.IndId < 2
             )x
       ON y.referenced_entity_name = x.name
       WHERE dbo.UDF_NthField(z.name,'_',1) IN ('PREP','BLD','RPT','CRT','TFM')
       AND dbo.UDF_NthField(z.name,'_',2) IN ('REF','WRK','DRV','EXP', 'MOD' ,'STG')
       AND referenced_entity_name NOT IN (SELECT DISTINCT name AS function_name FROM sys.objects WHERE type_desc LIKE '%FUNCTION%')
       AND referenced_id IS NOT  NULL


       --DROP TABLE  #TEMP
       ;WITH BASE AS
       (
       --------------------------------------------------
       --     STEP 1: CREATE BASELINE SYSTEM OBJECT TABLE
       --------------------------------------------------
       SELECT z.name 
             ,referenced_entity_name
             ,object_id
             ,referenced_id
             ,create_date
             ,referencing_class_desc
             ,DENSE_RANK() OVER(ORDER BY create_date) DRANK
             ,ROW_NUMBER() OVER(PARTITION BY z.name ORDER BY create_date,CASE WHEN CHARINDEX(referenced_entity_name,z.name,1) <> 0 THEN 1 ELSE 0 END) RNUM
             ,CASE WHEN CHARINDEX(referenced_entity_name,z.name,1) <> 0 THEN 1 ELSE 0 END Output_Flag
             ,CASE
                    WHEN dbo.UDF_NthField(z.name,'_',2) = 'REF' THEN 1
                    WHEN dbo.UDF_NthField(z.name,'_',2) = 'WRK' THEN 2
                    WHEN dbo.UDF_NthField(z.name,'_',2) IN ( 'DRV','STG') THEN 3
                    WHEN dbo.UDF_NthField(z.name,'_',2) IN ( 'EXP', 'MOD') THEN 4
                    ELSE NULL
             END CATEGORY
             ,x.rows
             ,dbo.UDF_NthField(z.name,'_',1)PROC_1
             ,dbo.UDF_NthField(z.name,'_',2)PROC_2
             ,CHAR(13)+'EXEC '+z.NAME SQL_STATEMENT_EXEC
             ,CASE
                    WHEN CASE WHEN CHARINDEX(referenced_entity_name,z.name,1) <> 0 THEN 1 ELSE 0 END = 0 THEN '/*I*/          SELECT TOP 100 * FROM ['+referenced_entity_name+'] --'+CONVERT(VARCHAR,ROWS)
                 WHEN CASE WHEN CHARINDEX(referenced_entity_name,z.name,1) <> 0 THEN 1 ELSE 0 END = 1 THEN '/*O*/             SELECT TOP 100 * FROM ['+referenced_entity_name+'] --'+CONVERT(VARCHAR,ROWS)
                    ELSE NULL
             END SQL_STATEMENT_SELECT
       FROM sys.objects z
       LEFT JOIN sys.sql_expression_dependencies y
       ON z.object_id = y.referencing_id
       LEFT JOIN 
             (
             --TABLE ROW COUNTS
             SELECT
                    sysobjects.Name
                    , sysindexes.Rows
             FROM sysobjects
             INNER JOIN sysindexes
                    ON sysobjects.id = sysindexes.id
             WHERE type = 'U'
             AND sysindexes.IndId < 2
             )x
       ON y.referenced_entity_name = x.name
       WHERE dbo.UDF_NthField(z.name,'_',1) IN ('PREP','BLD','RPT','CRT','TFM')
       AND dbo.UDF_NthField(z.name,'_',2) IN ('REF','WRK','DRV','EXP', 'MOD' ,'STG')
       AND referenced_entity_name NOT IN (SELECT DISTINCT name AS function_name FROM sys.objects WHERE type_desc LIKE '%FUNCTION%')
       AND referenced_id IS NOT  NULL
       )--SELECT * FROM BASE

       ,CODE AS
       (
       --------------------------------------------------
       --     STEP 2: BUILD STATEMENTS
       --------------------------------------------------
       
       --REFERENCE TABLE
       SELECT DISTINCT NAME AS PROC_NAME ,NAME AS TABLE_NAME ,DRANK ,0 AS RNUM ,0 AS Output_Flag ,CATEGORY ,SQL_STATEMENT_EXEC AS SQL_STATEMENT
       FROM BASE 
       WHERE PROC_1 = ('PREP') AND PROC_2 = ('REF')
       UNION ALL
       SELECT name   ,referenced_entity_name    ,DRANK ,RNUM ,Output_Flag ,CATEGORY ,SQL_STATEMENT_SELECT
       FROM BASE
       WHERE PROC_1 = ('PREP') AND PROC_2 = ('REF')
       UNION ALL

       --WORKING TABLE
       SELECT DISTINCT NAME AS PROC_NAME ,NAME AS TABLE_NAME ,DRANK ,0 AS RNUM ,0 AS Output_Flag ,CATEGORY ,SQL_STATEMENT_EXEC AS SQL_STATEMENT
       FROM BASE 
       WHERE PROC_1 = ('BLD') AND PROC_2 = ('WRK')
       UNION ALL
       SELECT name   ,referenced_entity_name    ,DRANK ,RNUM ,Output_Flag ,CATEGORY ,SQL_STATEMENT_SELECT
       FROM BASE
       WHERE PROC_1 = ('BLD') AND PROC_2 = ('WRK')
       UNION ALL

       --STAGING TABLE
       SELECT DISTINCT NAME AS PROC_NAME ,NAME AS TABLE_NAME ,DRANK ,0 AS RNUM ,0 AS Output_Flag ,CATEGORY ,SQL_STATEMENT_EXEC AS SQL_STATEMENT
       FROM BASE 
       WHERE (PROC_1 = ('TFM') AND PROC_2 = ('DRV'))
             OR (PROC_1 = ('BLD') AND PROC_2 = ('STG'))
       UNION ALL
       SELECT name   ,referenced_entity_name    ,DRANK ,RNUM ,Output_Flag ,CATEGORY ,SQL_STATEMENT_SELECT
       FROM BASE
       WHERE (PROC_1 = ('TFM') AND PROC_2 = ('DRV'))
             OR (PROC_1 = ('BLD') AND PROC_2 = ('STG'))
       UNION ALL

       --REPORTING TABLE
       SELECT DISTINCT NAME AS PROC_NAME ,NAME AS TABLE_NAME ,DRANK ,0 AS RNUM ,0 AS Output_Flag ,CATEGORY ,SQL_STATEMENT_EXEC AS SQL_STATEMENT
       FROM BASE 
       WHERE (PROC_1 = ('RPT') AND PROC_2 = ('EXP'))
             OR (PROC_1 = ('CRT') AND PROC_2 = ('MOD'))
       UNION ALL
       SELECT name   ,referenced_entity_name    ,DRANK ,RNUM ,Output_Flag ,CATEGORY ,SQL_STATEMENT_SELECT
       FROM BASE
       WHERE (PROC_1 = ('RPT') AND PROC_2 = ('EXP'))
             OR (PROC_1 = ('CRT') AND PROC_2 = ('MOD'))
       

       --HEADERS
       UNION ALL
       SELECT NULL,NULL,-1,-1,-1,1,CHAR(13)+'--------------------------------------------------' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,1,'--   PREPARE REFERENCE TABLES' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,1,'--------------------------------------------------' SQL_STATEMENT
       UNION ALL
       SELECT NULL,NULL,-1,-1,-1,2,CHAR(13)+'--------------------------------------------------' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,2,'--   BUILD WORKING TABLES' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,2,'--------------------------------------------------' SQL_STATEMENT
       UNION ALL
       SELECT NULL,NULL,-1,-1,-1,3,CHAR(13)+'--------------------------------------------------' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,3,'--   BUILD STAGING TABLES' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,3,'--------------------------------------------------' SQL_STATEMENT
       UNION ALL
       SELECT NULL,NULL,-1,-1,-1,4,CHAR(13)+'--------------------------------------------------' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,4,'--   EXPORT REPORTING TABLES' SQL_STATEMENT UNION ALL
       SELECT NULL,NULL,-1,-1,-1,4,'--------------------------------------------------' SQL_STATEMENT
       )
       ,CTE_PREP AS
       (
       SELECT ROW_NUMBER() OVER(ORDER BY CATEGORY,DRANK,RNUM,Output_Flag) CTE_RNUM
             ,COUNT(*) over() RCOUNT
             ,CAST(ISNULL(SQL_STATEMENT,'--NULL') AS VARCHAR(MAX)) SQL_STATEMENT
       FROM CODE
       )--SELECT * FROM CTE_PREP
       ,CTE AS
       (
       SELECT CTE_RNUM
             ,SQL_STATEMENT
             ,RCOUNT
       FROM CTE_PREP
       WHERE CTE_RNUM = 1
             UNION ALL 
       SELECT z.CTE_RNUM
             ,CAST(y.SQL_STATEMENT+CHAR(13)+z.SQL_STATEMENT AS VARCHAR(MAX))
             ,z.RCOUNT
       FROM CTE_PREP z
       INNER JOIN CTE y
       ON z.CTE_RNUM = y.CTE_RNUM + 1
       )
       SELECT SQL_STATEMENT 
       INTO #TEMP
       FROM CTE
       WHERE CTE_RNUM - RCOUNT = 0
       OPTION(MAXRECURSION 0)

       --------------------------------------------------
       --     STEP 3: WRITE MASTER PROC
       --------------------------------------------------
       DECLARE @SQL_STRING VARCHAR(MAX)
       SET @SQL_STRING =
             (
             --SELECT  
             --     CASE 
             --           WHEN OBJECT_ID('__MASTER_PROC_'+DB_NAME())IS NULL THEN 'CREATE PROCEDURE __MASTER_PROC_'+DB_NAME()+CHAR(13)+' AS'+SQL_STATEMENT 
             --           ELSE 'ALTER PROCEDURE __MASTER_PROC_'+DB_NAME()+CHAR(13)+' AS'+SQL_STATEMENT 
             --     END STRING
             SELECT 'CREATE PROCEDURE __MASTER_PROC_'+DB_NAME()+CHAR(13)+' AS'+SQL_STATEMENT AS STRING
             FROM #TEMP
             )
       EXEC (@SQL_STRING)
       --PRINT 'MASTER PROC SUCCESFULLY '+dbo.NthField(@SQL_STRING,' ',1)+'ED'
       
       --SELECT * FROM BASE
       
       PRINT 'MASTER PROC SUCCESFULLY CREATED'


-----------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
