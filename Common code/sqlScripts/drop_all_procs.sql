DECLARE @procName NVARCHAR(500)
DECLARE @schemaName NVARCHAR(500)
DECLARE @dropQuery NVARCHAR(1000)
DECLARE procCursor CURSOR FOR 
    SELECT [schema_name] = SCHEMA_NAME(schema_id), [name]
    FROM sys.procedures 
    WHERE type_desc = 'SQL_STORED_PROCEDURE' AND is_ms_shipped = 0;

OPEN procCursor
FETCH NEXT FROM procCursor INTO @schemaName, @procName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @dropQuery = 'DROP PROCEDURE [' + @schemaName + '].[' + @procName + ']'
    EXEC (@dropQuery)
    FETCH NEXT FROM procCursor INTO @schemaName, @procName
END

CLOSE procCursor
DEALLOCATE procCursor
