IF object_id('[dbo].[UDF_RemoveNonAlphaCharacters]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_RemoveNonAlphaCharacters]
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* this function wil remove all none-alphabetical characters
*/
CREATE FUNCTION UDF_RemoveNonAlphaCharacters(@Temp VarChar(1000)) 
Returns VarChar(1000) 
AS 
Begin 
 
    While PatIndex('%[^a-z]%', @Temp) > 0 
        Set @Temp = Stuff(@Temp, PatIndex('%[^a-z]%', @Temp), 1, '') 
 
    Return @TEmp 
End
GO
