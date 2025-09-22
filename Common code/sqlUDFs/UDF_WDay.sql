IF object_id('[dbo].[UDF_WDay]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_WDay]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_WDay]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[UDF_WDay] ( @DateIn AS DATETIME )
RETURNS VARCHAR(15)
AS 
/* This procedure returns the day of the week a specified date
falls on */
BEGIN
DECLARE @int INT
SET @int = 0
IF @DateIn IS NULL
    OR @DateIn = 0 
    RETURN 'Error Date In is incorrect'
SET @int = DATEDIFF(day, 0, @DateIn) - ( FLOOR(DATEDIFF(day, 0,
                                                      @DateIn) / 7)
                                         * 7 )
IF @int = 1 
    RETURN 'Tuesday'
ELSE 
    IF @int = 2 
        RETURN 'Wednesday'
    ELSE 
        IF @int = 3 
            RETURN 'Thursday'
        ELSE 
            IF @int = 4 
                RETURN 'Friday'
            ELSE 
                IF @int = 5 
                    RETURN 'Saturday'
                ELSE 
                    IF @int = 6 
                        RETURN 'Sunday'
                    ELSE 
                        IF @int = 0 
                            RETURN 'Monday'
RETURN 'Error'
END



GO