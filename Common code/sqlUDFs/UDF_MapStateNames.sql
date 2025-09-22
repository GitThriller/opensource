GO
DECLARE @func_name VARCHAR(255) = 'UDF_MapStateNames'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_MapStateNames(@String AS NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:

This function takes a range of values and attempts to map them to one of the 8 standard Australian state names
If it cannot identify the state, it will return NULL

*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 
	IF @String = '' OR @String IS NULL 
	BEGIN
		RETURN NULL
	END

	SET @String = dbo.UDF_AlphasOnly(@String)

	IF @String IN ('NEWSOUTHWALES','NSW')
	BEGIN
		RETURN 'NSW'
	END
	ELSE IF @String IN ('VICTORIA','VIC')
	BEGIN
		RETURN 'VIC'
	END
	ELSE IF @String IN ('SOUTHAUSTRALIA','SA')
	BEGIN
		RETURN 'SA'
	END
	ELSE IF @String IN ('TASMANIA','TAS')
	BEGIN
		RETURN 'TAS'
	END
	ELSE IF @String IN ('WESTAUSTRALIA','WESTERNAUSTRALIA','WA')
	BEGIN
		RETURN 'WA'
	END
	ELSE IF @String IN ('NORTHERNTERRITORY','THENORTHERNTERRITORY','NORTHTERRITORY','NT')
	BEGIN
		RETURN 'NT'
	END
	ELSE IF @String IN ('QUEENSLAND','QLD')
	BEGIN
		RETURN 'QLD'
	END
	ELSE IF @String IN ('AUSTRALIANCAPITALTERRITORY','THEAUSTRALIANCAPITALTERRITORY','AUSTRALIACAPITALTERRITORY','ACT')
	BEGIN
		RETURN 'ACT'
	END

	RETURN NULL 
END
GO
