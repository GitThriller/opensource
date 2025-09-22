IF OBJECT_ID('UDF_NthField') IS NOT NULL
BEGIN
	DROP FUNCTION UDF_NthField
END
GO
CREATE FUNCTION UDF_NthField(@String NVARCHAR(4000),@Separator NVARCHAR(4000),@Field_Number SMALLINT)
RETURNS NVARCHAR(4000)
AS
/*
This function returns the nth (@Field_Number) field in a string separated by @Separator.
This is a modification of the original code that outlines the treatment of exceptions for easy manipulation.
It also accepts separators of more than one character.
Modified by Bryan Ye 130526


Modified by Andrew Chester 161010 to resolve a bug introduced by changing the input to NVARCHAR from VARCHAR
To help prevent bugs being introduced in future modifications of this function, please run the following select statement and ensure that the output matches the comments in each line. 

SELECT dbo.UDF_NthField('happy fun time',' ',1) --happy
,dbo.UDF_NthField('happy fun time',' ',2) --fun
,dbo.UDF_NthField('happy fun time',' ',3) --time

SELECT dbo.UDF_NthField('happy, fun, time',', ',1) --happy
,dbo.UDF_NthField('happy, fun, time',', ',2) --fun
,dbo.UDF_NthField('happy, fun, time',', ',3) --time

SELECT dbo.UDF_NthField('happy fun time','',1) --expect error
,dbo.UDF_NthField('happy fun time','',2) --expect error
,dbo.UDF_NthField('happy fun time','',3) --expect error

SELECT dbo.UDF_NthField('happy fun time',NULL,1) --expect error
,dbo.UDF_NthField('happy fun time',NULL,2) --expect error
,dbo.UDF_NthField('happy fun time',NULL,3) --expect error

*/
BEGIN

	--Throw error if separator is null or blank
	--Note: RAISEERROR cannot be used within a function. This code is a hack to throw error if invalid separator is used.
	--Note 2: the function will be fully operational if the following IF statement is commented out. But a blank or NULL separator will generate blank or NULL respectively.
	IF ISNULL(DATALENGTH(@Separator),0) = 0
		RETURN CAST('Error reason: Null or blank Separator' AS INT)

	--If the separator cannot be found in the string, and you are just asking for the first 'word', then return the entire string.
	--Note: the function will be fully operational if the following IF statement is commented out. But the first 'word' in a string where the separator does not exist will return blank.
	IF @Field_Number = 1 AND CHARINDEX(@Separator,@String) = 0
		RETURN @String

	--If string is null / blank or separator does not exist in string then return blank
	--Note: the function will be fully operational if the following IF statement is commented out. But NULL strings will return NULL.
	IF ISNULL(@String,'') = '' OR CHARINDEX(@Separator,@String) = 0
		RETURN ''

	DECLARE @field_counter SMALLINT = 1
	DECLARE @start_pos SMALLINT = 1
	DECLARE @end_pos SMALLINT = CHARINDEX(@Separator,@String)

	WHILE @field_counter < @Field_Number
	BEGIN
		--if separator no longer exists return blank
		IF @end_pos = 0
			RETURN ''

		SET @field_counter += 1
		SET @start_pos = @end_pos + LEN(@Separator + '#') - 1 --Note that the hash is added to solve the problem that LEN function does not calculate spaces at the end of strings. Any other character (that is not space) would work as well.
		SET @end_pos = CHARINDEX(@Separator,@String,@start_pos)
	END 
	
	RETURN SUBSTRING(@String,@start_pos,CASE @end_pos WHEN 0 THEN LEN(@String + '#') ELSE @end_pos END - @start_pos)
END
GO
