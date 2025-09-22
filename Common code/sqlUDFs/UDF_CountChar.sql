GO
DECLARE @func_name VARCHAR(255) = 'UDF_CountChar'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_CountChar
(
	@String VARCHAR(MAX)
	,@CharToCount VARCHAR(MAX)
)
RETURNS INT 
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:

Count number of times a sequence of characters appear in a string.

*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 
	IF DATALENGTH(@String) = 0 OR DATALENGTH(@CharToCount) = 0
	BEGIN
		RETURN 0
	END

	IF @String IS NULL OR @CharToCount IS NULL 
	BEGIN
		RETURN NULL 
	END

	RETURN (DATALENGTH(@String)-DATALENGTH(REPLACE(@String,@CharToCount,'')))/DATALENGTH(@CharToCount)
END
GO
