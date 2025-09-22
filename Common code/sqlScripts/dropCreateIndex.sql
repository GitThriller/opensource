GO
DECLARE @proc_name VARCHAR(255) = 'dbo.dropCreateIndex'
IF OBJECT_ID(@proc_name) IS NULL
BEGIN
	EXEC('CREATE PROC '+@proc_name+' AS')
END
GO
ALTER PROC dbo.dropCreateIndex  
     @tableName NVARCHAR(4000)
	,@clusteredIndex BINARY
    ,@column1 NVARCHAR(4000)
    ,@column2 NVARCHAR(4000) = Null
    ,@column3 NVARCHAR(4000) = Null
    ,@column4 NVARCHAR(4000) = Null
    ,@indexName NVARCHAR(4000)
    
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:
	Drop creates index

	If a clustered index, drops any existing clustered index


Execute example
	EXEC dbo.dropCreateIndex @tableName = N'dbo.WRK_TIMESHEET_ACTIVITY', -- nvarchar(4000)
	    @clusteredIndex = 0, -- binary(1)
	    @column1 = N'[WBSLevel2Code] ASC', -- nvarchar(4000)
	    @column2 = N' [EtimeEngagementCode] ASC', -- nvarchar(4000)
	    @indexName = N'IDX_WRK_TIMESHEET_WBSL2Code_EngCode' -- nvarchar(4000)
*/
----------------------------------------------------------------
----------------------------------------------------------------

    BEGIN
		DECLARE @SQL NVARCHAR(MAX)
		DECLARE @columnIndexStr NVARCHAR(MAX)
		DECLARE @indexTypeStr NVARCHAR(MAX) = (IIF(@clusteredIndex = 1, 'CLUSTERED', 'NONCLUSTERED'))
		DECLARE @existingClusteredIndex NVARCHAR(MAX)

		-- Drop clustered index if one exists (cannot make another)
		-- Else drop non-clustered if exsists
		
        IF @clusteredIndex = 1 
			BEGIN
				-- Get existing clustered index
				SELECT  @existingClusteredIndex = [name]
				FROM    sys.indexes
				WHERE   [object_id] = OBJECT_ID(@tableName) 
						AND type_desc = 'CLUSTERED'

				-- Drop exsiting index
				SET @SQL = 'DROP INDEX ' + @existingClusteredIndex + ' ON ' + @tableName
				IF @SQL IS NOT NULL
					BEGIN
						PRINT('Dropping existing clustered index')
						PRINT(@SQL)
						EXEC sp_executesql  @SQL
					END 
			END
		
		-- Drop if exists by name 
		-- eg. If changing from non to clustered need to drop by name first
		IF EXISTS ( SELECT  *
					FROM    sys.indexes
					WHERE   name = @indexName
							AND [object_id] = OBJECT_ID(@tableName) )
			BEGIN 
				SET @SQL = 'DROP INDEX ' + @indexName + ' ON ' + @tableName
				PRINT(@SQL) 
				EXEC sp_executesql   @SQL
			END
 

		-- Create index
		SET @columnIndexStr = CONCAT(@column1, ISNULL(', '+@column2, ''), ISNULL(', '+ @column3, ''), ISNULL(', '+@column4, ''))
		SET @SQL = CONCAT('CREATE ', @indexTypeStr, ' INDEX ', @indexName, ' ON ', @tableName, ' ( ', @columnIndexStr, ' )	')
		PRINT(@sql)	
		EXEC sp_executesql @SQL

    END; 