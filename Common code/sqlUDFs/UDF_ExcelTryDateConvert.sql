IF object_id('[dbo].[UDF_ExcelTryDateConvert]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_ExcelTryDateConvert]
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION UDF_ExcelTryDateConvert(@DateNumber AS VARCHAR(255))
RETURNS DATETIME
AS
/*
Converts excel date time values.
Created by Ben Russell 120701
Updated by Bryan Ye 121212
Updated by Bryan Ye 130314
Updated by Bryan Ye 130820
Updated by Emmett Richardson 20190815

Excel data convert but will return null if unable to convert rather than failing. See UDF_ExcelTryDateConvert for details.
*/
BEGIN
	IF @DateNumber = '' OR ISNULL(TRY_CAST(@DateNumber AS FLOAT),0) = 0
		RETURN NULL

	DECLARE @DATE DATETIME
	DECLARE @TIMENUMBER FLOAT
	DECLARE @RETDATE DATETIME

	SET @DATE = DATEADD(DAY,(ROUND(CAST(@DateNumber AS FLOAT),0)-2),'1900-01-01')

	--Correction for pre-March 1900
	IF @DATE < '1900-03-01'
		SET @DATE = DATEADD(DAY,1,@DATE)

	SET @TIMENUMBER = CAST(@DateNumber AS FLOAT)- ROUND(CAST(@DateNumber AS FLOAT),0)
	SET @RETDATE = DATEADD(SECOND,CAST(ROUND(60*60*24*@TIMENUMBER,0) AS INT),@DATE)
	
	--Note RAISEERROR cannot be used within a function. This code is a hack to throw error as detailed above.
	IF @RETDATE < '1900-01-01' OR @RETDATE > '2100-02-28'
	BEGIN
		RETURN CAST('Date outside acceptance range! See function UDF_ExcelTryDateConvert for details.' AS INT)
	END

	RETURN @RETDATE
END
GO