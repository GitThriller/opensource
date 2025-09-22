IF object_id('[dbo].[UDF_NumbersOnly]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_NumbersOnly]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_NumbersOnly]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [dbo].[UDF_NumbersOnly] ( @String AS NVARCHAR(255) )
RETURNS VARCHAR(255)
AS 
    BEGIN
        DECLARE @cnt INT
        DECLARE @RetString VARCHAR(255)
        SET @cnt = 1
        SET @RetString = ''
        IF ( LEN(@String) = 0 ) 
            RETURN ''
        WHILE ( @cnt <= LEN(@String) ) 
            BEGIN
                IF ISNUMERIC(SUBSTRING(@String, @cnt, 1)) = 1
                    AND SUBSTRING(@String, @cnt, 1) <> '-'
                    AND SUBSTRING(@String, @cnt, 1) <> '+'
                    AND SUBSTRING(@String, @cnt, 1) <> '.'
                    AND SUBSTRING(@String, @cnt, 1) <> ','
                    AND SUBSTRING(@String, @cnt, 1) <> ' ' 
                    SET @RetString = @RetString + SUBSTRING(@String, @cnt, 1)
                SET @cnt = @cnt + 1
            END
        RETURN @RetString
    END



GO