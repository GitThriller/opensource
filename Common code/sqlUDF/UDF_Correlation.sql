

IF OBJECT_ID('UDF_Correlation') IS NOT NULL
BEGIN
Drop AGGREGATE UDF_Correlation
END

GO
CREATE AGGREGATE UDF_Correlation(@value1 FLOAT,@value2 FLOAT)
RETURNS FLOAT
/*
Aggregate function that calculates correlation between 2 sets of values, driven by assembly written in C#
Created by Bryan Ye 130523
*/
EXTERNAL NAME [UtilClr].[UtilClr.Correlation]
GO