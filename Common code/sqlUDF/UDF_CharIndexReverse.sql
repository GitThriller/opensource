

IF OBJECT_ID('UDF_CharIndexReverse') IS NOT NULL
BEGIN
	Drop FUNCTION UDF_CharIndexReverse
END

GO

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	----------------------------------------------------------------
	----------------------------------------------------------------
	-- Update History:
	--	Version 0.1 (YYMMDD): Kim Lam - Created base script
	----------------------------------------------------------------
	/*
	Script Purpose:
		Function of charindex but starting the look up from the end 
		of the string.

		Returns the index of the first found @sep, with the lookup
		starting from the back. 

		Example:
		dbo.UDF_CharIndexReverse ('123','aaabbb123ccc123ddd') = 13
		dbo.UDF_CharIndexReverse ('a','aaabbb123ccc123ddd') = 3

	*/
	----------------------------------------------------------------
	----------------------------------------------------------------
	CREATE FUNCTION [dbo].[UDF_CharIndexReverse] 
	(	
		@sep varchar(MAX)
		,@string varchar(MAX)
	)
	RETURNS int
	AS
	BEGIN
		DECLARE @ind INT = (SELECT CHARINDEX(REVERSE(@sep),REVERSE(@string)))
		DECLARE @str_len INT = (SELECT LEN(@string))
		SET @ind = @str_len - @ind - (LEN(@sep) - 1) + 1

		RETURN @ind

	END
	GO