IF object_id('[dbo].[UDF_RepeatedString]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_RepeatedString]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_RepeatedString]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE FUNCTION [dbo].[UDF_RepeatedString] ( @String AS NVARCHAR(100) )
RETURNS INT
AS 
    BEGIN
        DECLARE @cnt INT
        DECLARE @char CHAR(1)
        SET @cnt = 1
        SET @char = LEFT(@String, 1)
        IF LEN(@String) <= 1 
            RETURN 0
        WHILE ( @cnt <= LEN(@String) ) 
            BEGIN
/* Return 0 if it is NOT a repeating string */
                IF ( SUBSTRING(@String, @cnt, 1) <> @char ) 
                    RETURN 0 
/* Return 1 if it is a repeating string */
                SET @cnt = @cnt + 1
            END
        RETURN 1
    END





GO
