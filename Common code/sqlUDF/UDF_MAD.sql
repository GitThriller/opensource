
IF OBJECT_ID('UDF_MAD') IS NOT NULL
BEGIN
	Drop AGGREGATE UDF_MAD
END


GO	

CREATE AGGREGATE UDF_MAD(@input FLOAT)
RETURNS FLOAT
/*
Aggregate function that calculates MAD, driven by assembly written in C#
Created by Bryan Ye 121009
*/
EXTERNAL NAME [UtilClr].[UtilClr.MAD]
GO