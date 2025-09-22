GO
DECLARE @func_name VARCHAR(255) = 'UDF_AlphasOnly'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_AlphasOnly(@String NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:

Strip out non-alphabets from string
*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 
	IF @String = '' OR @String IS NULL 
	BEGIN
		RETURN NULL
	END

	WHILE PATINDEX('%[^A-Z]%', @String) > 0
	BEGIN
		SET @String = REPLACE(@String, SUBSTRING(@String, PATINDEX('%[^A-Z]%', @String), 1), '')
	END

	RETURN @String
END
GO