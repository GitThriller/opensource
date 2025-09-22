IF object_id('[dbo].[UDF_Trim]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_Trim]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_Trim]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[UDF_Trim] ( @String AS NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS 
    BEGIN
/* This function removes all multi spaces in the string and replaces them with a single space and removes
leading or trailing spaces.
EG 
   Mick      Power    .
becomes
Mick Power .
*/
        DECLARE @AString NVARCHAR(MAX)
        DECLARE @RetString NVARCHAR(MAX)
        SET @String = LTRIM(RTRIM(@String))
        SET @String = REPLACE(@String, '  ', ' ')
        WHILE ( CHARINDEX('  ', @String, 1) <> 0 ) 
            BEGIN
                SET @String = REPLACE(@String, '  ', ' ')
            END
        SET @RetString = @String
        RETURN @RetString
    END


GO