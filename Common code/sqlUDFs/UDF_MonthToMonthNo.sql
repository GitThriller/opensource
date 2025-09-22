IF OBJECT_ID('UDF_MonthToMonthNo') IS NOT NULL
BEGIN
Drop FUNCTION UDF_MonthToMonthNo
END

GO

--This function is designed to convert week number to date
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_MonthToMonthNo]
(@Month NVARCHAR(3))
RETURNS INT
AS
BEGIN 

DECLARE @TempMonth INT

IF @Month = 'Jan'
BEGIN
	SET @TempMonth = 1
END

IF @Month = 'Feb'
BEGIN
	SET @TempMonth = 2
END

IF @Month = 'Mar'
BEGIN
	SET @TempMonth = 3
END

IF @Month = 'Apr'
BEGIN
	SET @TempMonth = 4
END

IF @Month = 'May'
BEGIN
	SET @TempMonth = 5
END

IF @Month = 'Jun'
BEGIN
	SET @TempMonth = 6
END

IF @Month = 'Jul'
BEGIN
	SET @TempMonth = 7
END

IF @Month = 'Aug'
BEGIN
	SET @TempMonth = 8
END

IF @Month = 'Sep'
BEGIN
	SET @TempMonth = 9
END

IF @Month = 'Oct'
BEGIN
	SET @TempMonth = 10
END

IF @Month = 'Nov'
BEGIN
	SET @TempMonth = 11
END

IF @Month = 'Dec'
BEGIN
	SET @TempMonth = 12
END

RETURN @TempMonth

END
GO