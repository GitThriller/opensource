IF object_id('[dbo].[UDF_PadRight]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_PadRight]
END


GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION UDF_PadRight(@String AS VARCHAR(255), @StringLen AS INT, @Char AS CHAR)
RETURNS VARCHAR(255)
/*
Fixed bug caused by the LEN function in the original function by replacing with DATALENGTH
Also created a separate section for handling of special situations to allow easy user manipulation where necessary.
Modified by Bryan Ye 130702
*/
AS
BEGIN
IF DATALENGTH(@String) > @StringLen
	RETURN CAST('String value "'+@String+'" is longer than prescripted string length. See UDF_PadRight.' AS INT)

RETURN @String+REPLICATE(@Char,@StringLen - DATALENGTH(@String))
END
GO
