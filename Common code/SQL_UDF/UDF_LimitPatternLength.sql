IF object_id('[dbo].[UDF_LimitPatternLength]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_LimitPatternLength]
END

GO

-- This function limits the occurrence of certain characters in a row to the specified number of times. 
-- For example:
-- SELECT dbo.UDF_LimitPatternLength('ahhhhhhhhhhhhhhhhhhhhhhh', 'h',2); returns 'ahh'
-- SELECT dbo.UDF_LimitPatternLength('hahhahhahhahhahgreathahhahhahhah', 'hah',3); returns 'hahhahhahgreathahhahhah'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[UDF_LimitPatternLength](@String as nvarchar(max),@Pattern NVARCHAR(255), @Limit INT)
Returns nvarchar(max)
AS


BEGIN

	WHILE REPLACE(@String,dbo.UDF_RepeatCharNTimes(@Pattern,@Limit+1),dbo.UDF_RepeatCharNTimes(@Pattern,@Limit))<>@String
	BEGIN

		SET @String=REPLACE(@String,dbo.UDF_RepeatCharNTimes(@Pattern,@Limit+1),dbo.UDF_RepeatCharNTimes(@Pattern,@Limit))

	END

	RETURN @String

END

GO

