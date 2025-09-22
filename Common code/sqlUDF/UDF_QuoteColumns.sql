IF object_id('[dbo].[UDF_QuoteColumns]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_QuoteColumns]
END

GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION UDF_QuoteColumns(@String AS NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
/*
Splits a comma delimited string into a table with it's components and then quotes them and reconcatenates them
*/
AS
BEGIN

DECLARE @RET_VAL NVARCHAR(MAX)

SELECT @RET_VAL =  dbo.UDF_OrderedConcat(DTT_ID, QUOTENAME(ROW_VALUE),',')  FROM DBO.UDF_StringSplit(@String,',')
RETURN @RET_VAL

END
GO
