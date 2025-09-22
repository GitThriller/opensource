IF object_id('[dbo].[UDF_RemLeadingChar]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_RemLeadingChar]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_RemLeadingChar]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     function [dbo].[UDF_RemLeadingChar](@Char as char, @String as nvarchar(255))
Returns varchar(255)
AS
BEGIN
declare @cnt int
declare @Pos int
declare @retstring nvarchar(255)
set @cnt = 1
set @retstring = ''
set @Pos = 0
-- Get position of first character that is not @Char
while (@cnt <= len(@String) and @Pos = 0)
begin
       if Substring(@String, @cnt, 1) <> @Char
              set @Pos = @cnt
       set @cnt = @cnt + 1
end
if @Pos = 0
       set @retstring = @String
else
       set @Retstring = Right(@String, len(@String)-@Pos+1)
Return @retstring
END



GO

/*
this function remove the character specified in the first part of the function (@char) from the beginning of 
the string specified in the second element of the function (@string)

For example:
[dbo].[UDF_RemLeadingChar]('a', 'abcd')
will return 'bcd'

[dbo].[UDF_RemLeadingChar]('a', 'bbcd')
will return 'bbcd'

--Eva
*/