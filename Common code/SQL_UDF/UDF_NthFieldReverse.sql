
IF OBJECT_ID('UDF_NthFieldReverse') IS NOT NULL
BEGIN
	DROP FUNCTION UDF_NthFieldReverse
END



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION UDF_NthFieldReverse(@String VARCHAR(8000),@Separator VARCHAR(8000),@Field_Number SMALLINT)
RETURNS VARCHAR(8000)
AS
/*
Finds the nth field from the end defined by @Separator.
Created by Bryan Ye 130526
*/
BEGIN
	RETURN REVERSE(dbo.UDF_NthField(REVERSE(@String),REVERSE(@Separator),@Field_Number))
END
GO
