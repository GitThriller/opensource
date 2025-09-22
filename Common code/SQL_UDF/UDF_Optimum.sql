GO
IF OBJECT_ID('UDF_Optimum') IS NOT NULL 
BEGIN
	DROP FUNCTION UDF_Optimum
END
GO
CREATE FUNCTION UDF_Optimum
(
	@MIN_or_MAX CHAR(3)
	,@COMPARISON1 SQL_VARIANT 
	,@COMPARISON2 SQL_VARIANT 
	,@TARGET1 SQL_VARIANT 
	,@TARGET2 SQL_VARIANT 
)
RETURNS SQL_VARIANT 
/*
Calculates minimum or maximum of the comparison values and return the corresponding target value.
Make sure that the data type of VALUE1 and VALUE2 is the same, otherwise you would be comparing
their underlying character indices which may not be intuitive.
Created by Bryan Ye 141030
*/
AS
BEGIN
	DECLARE @optimum SQL_VARIANT

	--Output error if incorrect value is assigned to @MIN_or_MAX
	IF @MIN_or_MAX NOT IN ('MIN','MAX')
	BEGIN
		RETURN CAST('First parameter must be either ''MIN'' or ''MAX''' AS INT)
	END
	
	--Pick non-null value
	IF @COMPARISON1 IS NULL AND @COMPARISON2 IS NULL 
	BEGIN
		RETURN NULL 
	END
	ELSE IF @COMPARISON1 IS NULL 
	BEGIN
		RETURN @TARGET2
	END
	ELSE IF @COMPARISON2 IS NULL 
	BEGIN
		RETURN @TARGET1
	END

	IF @TARGET1 IS NULL AND @TARGET2 IS NULL 
	BEGIN 
		SET @TARGET1 = @COMPARISON1
		SET @TARGET2 = @COMPARISON2
	END

	--Select minimum
	IF @MIN_or_MAX = 'MIN'
	BEGIN
		SET @optimum = CASE WHEN @COMPARISON1 < @COMPARISON2 THEN @TARGET1 ELSE @TARGET2 END 
	END
	--Select maximum
	ELSE
    BEGIN
		SET @optimum = CASE WHEN @COMPARISON1 > @COMPARISON2 THEN @TARGET1 ELSE @TARGET2 END 
    END

	RETURN @optimum
END
GO
