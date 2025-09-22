IF object_id('[dbo].[UDF_FuzzyStringMatch]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_FuzzyStringMatch]
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
UDF_FuzzyStringMatch(@Str1,@Str2,@Precision) returns 1 if there are consecutive characters (of length @Precision) from @Str1 in @Str2 
and returns 0 if there are no consecutive characters (of length @Precision) from @Str1 in @Str2

eg:
SELECT dbo.UDF_FuzzyStringMatch('Bikes', 'Mountain Bikes', 4) -- 1

SELECT dbo.UDF_FuzzyStringMatch('Bikes', 'Mountain Bikes', 5) -- 1

SELECT dbo.UDF_FuzzyStringMatch('Components', 'Bottom Brackets', 2) -- 1

SELECT dbo.UDF_FuzzyStringMatch('Components', 'Bottom Brackets', 3) -- 0

SELECT dbo.UDF_FuzzyStringMatch('Mountain Bikes', 'Bikes', 4) -- 1

SELECT dbo.UDF_FuzzyStringMatch('ab c234', ' c2', 3) -- 1

-Kevin Chieng
*/

CREATE FUNCTION UDF_FuzzyStringMatch
(
     @Str1 Nvarchar(4000)
     , @Str2 Nvarchar(4000)
     , @Precision int = 4 --This is the number of characters 
)
RETURNS bit
AS
BEGIN
     DECLARE @Str1Len int SET @Str1Len = LEN(@Str1)
     DECLARE @MaxPosition int SET @MaxPosition = @Str1Len - @Precision + 1
     DECLARE @Str1Extract Nvarchar(4000)
 
     DECLARE @i int = 1
     WHILE @i <= @MaxPosition BEGIN
           SET @Str1Extract = SUBSTRING(@Str1, @i, @Precision)
 
           IF @Str2 LIKE '%' + @Str1Extract + '%' BEGIN
                RETURN 1
           END
			
           SET @i = @i + 1
     END
 
     RETURN 0
 
END
GO