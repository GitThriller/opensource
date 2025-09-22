
IF OBJECT_ID('UDF_Median') IS NOT NULL
BEGIN
	Drop AGGREGATE UDF_Median
END

GO

CREATE AGGREGATE UDF_Median(@input FLOAT)
RETURNS FLOAT
/*
Aggregate function that calculates median, driven by assembly written in C#
Created by Bryan Ye 120920
*/
EXTERNAL NAME [UtilClr].[UtilClr.Median]
GO


