
IF OBJECT_ID('dbo.UDF_PullNumbersFromString') IS NOT NULL 
BEGIN
	DROP FUNCTION dbo.UDF_PullNumbersFromString
END
GO

CREATE  FUNCTION [dbo].[UDF_PullNumbersFromString] ( @String AS NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS 
    BEGIN

	--Remove commas as not needed and trim string
	SET @String=REPLACE(LTRIM(RTRIM(@String)),',','')

	DECLARE @INDEX INT=1
	DECLARE @LENGTH INT = LEN(@String)
	DECLARE @STRING_FROM_PREV_RUN NVARCHAR(MAX)=''
	DECLARE @RETURN_STRING NVARCHAR(MAX)=''

	--NOTE: THIS DOESN'T HANDLE FOR WHERE NUMBER EXPRESSED AS E^XXX AND ANY POWERS OR PLUS SIGNS
	--NOTE: THIS WILL ALSO PULL DATES OUT OF STRINGS

	--LOOP THROUGH THE STRING TO DETERMINE IF EACH CHARACTER IS NUMERIC AND IF IT IS, ADD IT'S INDEX TO THE INDEX STRING
	WHILE @INDEX<=@LENGTH
	BEGIN

	IF SUBSTRING(@String, @INDEX, 1) NOT IN ('%','/','-','.',',','0','1','2','3','4','5','6','7','8','9')
		BEGIN
		SET @String=STUFF(@String,@INDEX,1,'Z') --replace any non-numerics with Z to maintain length of string
		END


	SET @INDEX=@INDEX+1
	END


	
	--loop through string and replace characters that are out of place with Z (e.g. percentage at start, . at end, etc)
	WHILE @String<>@STRING_FROM_PREV_RUN --keep replacing characters until no more to replace
	BEGIN
	SET @STRING_FROM_PREV_RUN=@String
	
		SET @INDEX=1
		WHILE @INDEX<=@LENGTH
		BEGIN

			--Remove characters that should not be seen at the start of numeric expressions
			--and characters that should not be seen at the start if certain characters come next
				IF (SUBSTRING(@String, @INDEX,1) IN ('%','/','.',',') OR 
				(SUBSTRING(@String,@INDEX,1) IN ('%','/','-','.',',') AND SUBSTRING(@String,@INDEX+1,1) IN ('%','/','-','.',',')))
					AND (@INDEX=1 OR SUBSTRING(@String,@INDEX-1,1)='Z')
					BEGIN
						SET @String=STUFF(@String,@INDEX,1,'Z') --inserts Z to be deleted later but to maintain string length
					END	
			
			--Remove characters that should not be seen at the end of numeric expressions
			--and characters that should not be seen at the end if certain characters come before
				IF (SUBSTRING(@String, @INDEX,1) IN ('/','.',',','-') OR 
				(SUBSTRING(@String,@INDEX,1) IN ('%','/','-','.',',') AND SUBSTRING(@String,@INDEX-1,1) IN ('%','/','-','.',',')))
					AND (@INDEX=@LENGTH OR SUBSTRING(@String,@INDEX+1,1)='Z')
					BEGIN
						SET @String=STUFF(@String,@INDEX,1,'Z') --inserts Z to be deleted later but to maintain string length
					END	

			--Remove characters that should not be seen in the middle of numeric expressions
				IF (SUBSTRING(@String, @INDEX,1) IN ('-','%') OR 
				(SUBSTRING(@String,@INDEX,1) IN ('%','/','-','.',',') AND SUBSTRING(@String,@INDEX+1,1) IN ('%','/','-','.',',')))
				AND @INDEX<>1 AND @INDEX<>@LENGTH
				AND SUBSTRING(@String,@INDEX+1,1)<>'Z' AND SUBSTRING(@String,@INDEX-1,1)<>'Z'
					BEGIN
						SET @String=STUFF(@String,@INDEX,1,'Z') --inserts Z to be deleted later but to maintain string length
					END	

		SET @INDEX=@INDEX+1
		END
	END
   

	--Remove any repeating Zs to then replace Z with commas in order to separate out numbers

	SET @STRING_FROM_PREV_RUN=''
	
	WHILE @String<>@STRING_FROM_PREV_RUN
	BEGIN

	SET @STRING_FROM_PREV_RUN=@String
	
	SET @String=REPLACE(@String,'ZZ','Z')

		--While in loop, delete opening  Zs
		IF SUBSTRING(@String,1,1)='Z' 
		BEGIN
        SET @String=STUFF(@String,1,1,'')
		END 
		
		--While in loop, delete closing  Zs
		SET @LENGTH=LEN(@String) --reset length since this has likely changed
		IF SUBSTRING(@String,@LENGTH,1)='Z'
		BEGIN
		SET @String=STUFF(@String,@LENGTH,1,'')
		END
	
	END 

	--Replace Zs with commas

	SET @String=REPLACE(@String,'Z',', ')

	RETURN @String

END


