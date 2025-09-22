

IF OBJECT_ID('UDF_Quartile3') IS NOT NULL
BEGIN
Drop AGGREGATE UDF_Quartile3
END

GO
CREATE AGGREGATE UDF_Quartile3(@value1 FLOAT)
RETURNS FLOAT
/*
Aggregate function that calculates third quartile, driven by assembly written in C#
Created by Bryan Ye 130527
*/
EXTERNAL NAME [UtilClr].[UtilClr.Quartile3]
GO