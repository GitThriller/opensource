GO
DECLARE @func_name VARCHAR(255) = 'UDF_RepeatCharNTimes'
IF OBJECT_ID(@func_name) IS NULL
BEGIN
	EXEC('CREATE FUNCTION '+@func_name+'() RETURNS INT AS BEGIN RETURN 1 END')
END
GO
ALTER FUNCTION UDF_RepeatCharNTimes(@CHARACTER NVARCHAR(MAX)
										,@NUMBER_OF_TIMES_TO_REPEAT INT)
RETURNS NVARCHAR(MAX)
AS
----------------------------------------------------------------
----------------------------------------------------------------
/*
Script Purpose:

Takes a character or characters input and a number and returns a string with that character or characters repeated that number of times

*/
----------------------------------------------------------------
----------------------------------------------------------------
BEGIN 
DECLARE @OUTPUT NVARCHAR(MAX)

SET @OUTPUT=''

	WHILE @NUMBER_OF_TIMES_TO_REPEAT>0
	BEGIN

	SET @OUTPUT=@OUTPUT+@CHARACTER

	SET @NUMBER_OF_TIMES_TO_REPEAT=@NUMBER_OF_TIMES_TO_REPEAT-1
	END

RETURN @OUTPUT
	
END
