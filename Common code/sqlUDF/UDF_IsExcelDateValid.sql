
IF OBJECT_ID('dbo.UDF_IsExcelDateValid') IS NOT NULL 
BEGIN
	DROP FUNCTION dbo.UDF_IsExcelDateValid
END
GO

CREATE FUNCTION [dbo].[UDF_IsExcelDateValid](@DateNumber AS VARCHAR(255))
RETURNS TINYINT
AS
/*
Checks excel date time values for validity.
Created by Andrew Chester

*/
BEGIN
	DECLARE @RETFLAG TINYINT
    
	SET @RETFLAG =	CASE WHEN ISNUMERIC(@DateNumber) = 1 THEN
						CASE WHEN TRY_CONVERT(FLOAT,@DateNumber) BETWEEN 0 AND 73000
							THEN 1 
							ELSE 0
						END
					ELSE 0
				END
	
	RETURN @RETFLAG
END
