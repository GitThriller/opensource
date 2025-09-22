
IF OBJECT_ID('UDF_Quartile1') IS NOT NULL
BEGIN
Drop AGGREGATE UDF_Quartile1
END


go
CREATE AGGREGATE UDF_Quartile1(@value1 FLOAT)
RETURNS FLOAT
/*
Aggregate function that calculates first quartile, driven by assembly written in C#
Created by Bryan Ye 130527
*/
EXTERNAL NAME [UtilClr].[UtilClr.Quartile1]
GO