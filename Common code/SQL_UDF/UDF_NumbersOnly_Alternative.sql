IF OBJECT_ID('UDF_NumbersOnly_Alternative') IS NOT NULL 
BEGIN
	DROP FUNCTION UDF_NumbersOnly_Alternative
END
GO

CREATE FUNCTION UDF_NumbersOnly_Alternative(@String VARCHAR(255))
RETURNS VARCHAR(255)
AS
/*
this is an alternative numbers only function that will only look at the criterias listed below which only inlcudes 0- 9 , '.' and '-'

*/
BEGIN
	DECLARE @cnt INT
	DECLARE @RetString VARCHAR(255)
	SET @cnt = 1
	SET @RetString = ''
	DECLARE @char VARCHAR(255)
	SET @char = ''
	IF LEN(@String) = 0
		RETURN ''
		
	WHILE @cnt <= len(@String)
		BEGIN
		
			SET @char = SUBSTRING (@String, @cnt, 1)
			
			IF @char IN ('0','1','2','3','4','5','6','7','8','9','.','-','E','+')
				BEGIN 
					SET @RetString = @RetString + @char
				END
		
			SET @cnt = @cnt + 1
		END
	RETURN @RetString
END
