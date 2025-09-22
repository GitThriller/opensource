
IF OBJECT_ID('UDF_GetDateFromWeekNo') IS NOT NULL
BEGIN
Drop FUNCTION UDF_GetDateFromWeekNo
END

GO

--This function is designed to convert week number to date
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_GetDateFromWeekNo]
(@weekNo int , @yearNo  int)
RETURNS smalldatetime
AS
BEGIN 

DECLARE @tmpDate smalldatetime


set @tmpdate= cast(cast (@yearNo as varchar) + '-01-01' as smalldatetime)
-- jump forward x-1 weeks to save counting through the whole year 
set @tmpdate=dateadd(wk,@weekno-1,@tmpdate)

-- make sure weekno is not out of range
if @WeekNo <= datepart(wk,cast(cast (@yearNo as varchar) + '-12-31' as smalldatetime))
BEGIN
    WHILE (datepart(wk,@tmpdate)<@WeekNo)
    BEGIN
        set @tmpdate=dateadd(dd,1,@tmpdate)
    END
END
ELSE
BEGIN
    -- invalid weeknumber given
    set @tmpdate=null
END


RETURN @tmpDate

END
GO