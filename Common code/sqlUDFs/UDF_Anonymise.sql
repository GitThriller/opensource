GO
DECLARE @func_name VARCHAR(255) = 'UDF_Anonymise'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_Anonymise (@string NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:

Anonymise data content by changing every character to the next
one in alphabetical sequence.

For e.g. "ABC" becomes "BCD"; "bed" becomes "cfe".

*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 

DECLARE @cnt INT
DECLARE @newchar CHAR(1)
DECLARE @newstring NVARCHAR(4000)
SET @cnt = 0
SET @newstring = ''

WHILE @cnt <= LEN(@string)
BEGIN
	SET @newchar = CHAR(ASCII(SUBSTRING(@string,@cnt,1)) + 1)
	SET @cnt = @cnt + 1
	SET @newstring = CONCAT(@newstring,(@newchar))
END

RETURN @newstring

END
GO
