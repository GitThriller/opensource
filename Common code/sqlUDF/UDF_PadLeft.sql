IF OBJECT_ID('UDF_PadLeft') IS NOT NULL
BEGIN
	DROP FUNCTION UDF_PadLeft
END
GO

/*
This function takes a string, string length and character as inputs and pads the string on the left with the character up to the length specified.
If the length of the input string is longer than the length specified, an error message is returned.

e.g. SELECT dbo.UDF_PadLeft('Naomi was here', 20, '#') -- ######Naomi was here
*/

CREATE FUNCTION UDF_PadLeft(@String AS VARCHAR(255), @StringLen AS INT, @Char AS CHAR)
RETURNS VARCHAR(255)
/*
Fixed bug caused by the LEN function in the original function by replacing with DATALENGTH
Also created a separate section for handling of special situations to allow easy user manipulation where necessary.
Modified by Bryan Ye 130702
*/
AS
BEGIN
IF DATALENGTH(@String) > @StringLen
	RETURN CAST('String value "'+@String+'" is longer than prescripted string length. See UDF_PadLeft.' AS INT)

RETURN REPLICATE(@Char,@StringLen - DATALENGTH(@String))+@String
END
GO
