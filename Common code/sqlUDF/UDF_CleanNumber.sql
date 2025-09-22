IF OBJECT_ID('[dbo].[UDF_CleanNumber]') IS NOT NULL
    BEGIN
        DROP FUNCTION [dbo].[UDF_CleanNumber]
    END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_CleanNumber]
    (
     @InputString VARCHAR(1000)
    )
RETURNS VARCHAR(1000)
/*

	- Strips all non numeric values from a string

*/
AS
    BEGIN
	-- Loop while the string contains a non-numeric
        WHILE PATINDEX('%[^0-9]%', @InputString) > 0
            BEGIN
			-- Replace the non-numeric with '' and update the string
                SET @InputString = STUFF(@InputString, PATINDEX('%[^0-9]%', @InputString), 1, '')  
            END    
        RETURN @InputString
    END

GO
