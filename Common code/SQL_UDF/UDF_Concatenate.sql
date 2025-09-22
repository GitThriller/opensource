
IF OBJECT_ID('UDF_Concatenate') IS NOT NULL
BEGIN
	DROP AGGREGATE UDF_Concatenate
END


GO
CREATE AGGREGATE UDF_Concatenate(@input NVARCHAR(MAX),@separator NVARCHAR(255))
RETURNS NVARCHAR(MAX)
/*
Aggregate function that concatenates strings with a user defined separator, driven by assembly written in C#
Created by Bryan Ye 130430
*/
EXTERNAL NAME [UtilClr].[UtilClr.Concatenate]
GO

SELECT dbo.UDF_Concatenate('testing 101')