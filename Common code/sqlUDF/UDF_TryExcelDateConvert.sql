
IF OBJECT_ID('dbo.UDF_TryExcelDateConvert') IS NOT NULL 
BEGIN
	DROP FUNCTION dbo.UDF_TryExcelDateConvert
END
GO

CREATE FUNCTION [dbo].[UDF_TryExcelDateConvert](@DateNumber AS VARCHAR(255))
RETURNS DATETIME
AS
/*
Converts excel date time values.
Created by Ben Russell 120701
Updated by Bryan Ye 121212
Updated by Bryan Ye 130314
Updated by Bryan Ye 130820
Updated by Andrew Chester 160714

The excel serial number is the number of days from 1900-01-00. Therefore, serial number 1 represents 1900-01-01,
implying that if you add the serial number less one to 1900-01-01, you will get the date.

Note, however, that excel has a date conversion error related to the definition of leap years. When a year is
divisible by 100, then it needs to be divisible by 400 to be a leap year, and hence have the 29th of February.
Excel operates as though there is the 29th of February on any year divisible by 4 (including years like 1900).
Therefore excel has the day 1900-02-29, which means to get the correct date for days after that, you need to
subtract the serial number by one further.

As a result, the code used in this function takes away 2 from the serial number and adds onto 1900-01-01. This
means that any day before 1900-03-01 and any day after 2100-02-28 will be calculated incorrectly. Hence, the
function will throw an error if it falls outside the boundaries.

PS: This is actually not a bug of Excel. It is designed to work this way because it was truly a bug in Lotus 123
(the spreadsheet software that dominated the market when Excel was introduced). Microsoft decided to continue
Lotus' bug to be fully compatible.
*/
BEGIN
	IF @DateNumber = '' OR TRY_CAST(@DateNumber AS FLOAT) = 0 OR TRY_CAST(@DateNumber AS FLOAT) IS NULL
		RETURN NULL


	DECLARE @DATE DATETIME
	DECLARE @TIMENUMBER FLOAT
	DECLARE @RETDATE DATETIME

	SET @DATE = DATEADD(DAY,(ROUND(TRY_CAST(@DateNumber AS FLOAT),0)-2),'1900-01-01')

	--Correction for pre-March 1900
	IF @DATE < '1900-03-01'
		SET @DATE = DATEADD(DAY,1,@DATE)

	SET @TIMENUMBER = TRY_CAST(@DateNumber AS FLOAT)- ROUND(TRY_CAST(@DateNumber AS FLOAT),0)
	SET @RETDATE = DATEADD(SECOND,CAST(ROUND(60*60*24*@TIMENUMBER,0) AS INT),@DATE)
	
	--Note RAISEERROR cannot be used within a function. This code is a hack to throw error as detailed above.
	IF @RETDATE < '1900-01-01' OR @RETDATE > '2100-02-28'
	BEGIN
		RETURN NULL
	END

	RETURN @RETDATE
END

