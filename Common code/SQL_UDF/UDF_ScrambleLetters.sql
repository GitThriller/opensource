GO
DECLARE @func_name VARCHAR(255) = 'UDF_ScrambleLetters'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_ScrambleLetters(@String NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:


*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 

SET @String=REPLACE(@String,'a','c')
SET @String=REPLACE(@String,'b','u')
SET @String=REPLACE(@String,'c','e')
SET @String=REPLACE(@String,'d','g')
SET @String=REPLACE(@String,'e','z')
SET @String=REPLACE(@String,'f','p')
SET @String=REPLACE(@String,'g','q')
SET @String=REPLACE(@String,'h','x')
SET @String=REPLACE(@String,'i','tr')
SET @String=REPLACE(@String,'j','k')
SET @String=REPLACE(@String,'k','q')
SET @String=REPLACE(@String,'l','n')
SET @String=REPLACE(@String,'m','d')
SET @String=REPLACE(@String,'n','s')
SET @String=REPLACE(@String,'o','b')
SET @String=REPLACE(@String,'p','w')
SET @String=REPLACE(@String,'q','c')
SET @String=REPLACE(@String,'r','t')
SET @String=REPLACE(@String,'s','w')
SET @String=REPLACE(@String,'t','m')
SET @String=REPLACE(@String,'u','y')
SET @String=REPLACE(@String,'v','p')
SET @String=REPLACE(@String,'w','u')
SET @String=REPLACE(@String,'x','f')
SET @String=REPLACE(@String,'y','a')
SET @String=REPLACE(@String,'z','j')

RETURN @String
END
