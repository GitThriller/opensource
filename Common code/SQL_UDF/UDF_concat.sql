
IF OBJECT_ID('UDF_concat') IS NOT NULL
BEGIN
Drop AGGREGATE UDF_concat
END


/****** Object:  UserDefinedAggregate [dbo].[UDF_concat]    Script Date: 11/06/2015 6:56:16 PM ******/
CREATE AGGREGATE [dbo].[UDF_concat]
(@input [NVARCHAR](4000))
RETURNS[NVARCHAR](4000)
EXTERNAL NAME [CLR_StringConcat].[CLR_StringConcatenation.Concatenate]
GO
