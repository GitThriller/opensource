IF object_id('[dbo].[UDF_RemTrailingChar]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_RemTrailingChar]
END

GO

-- This function removes all instances of the specified char (including white spaces) from the end of an nvarchar argument. 
-- For example:
-- SELECT dbo.UDF_RemTrailingChar('h', 'ahhhhhhhhhhhhhhhhhhhhhhh'); returns 'a'
-- SELECT dbo.UDF_RemTrailingChar('h', 'hahhhhhhhhhhhhhhhhhhhhhhh'); returns 'ha'


/****** Object:  UserDefinedFunction [dbo].[UDF_RemTrailingChar]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE      function [dbo].[UDF_RemTrailingChar](@Char as char, @String as nvarchar(255))
Returns varchar(255)
AS


BEGIN

declare @cnt int
declare @Pos int
declare @retstring nvarchar(255)

set @cnt = len(@String)
set @retstring = ''
set @Pos = 0

-- Get position of last character that is not @Char

while (@cnt >= 1 and @Pos = 0)
begin
       if Substring(@String, @cnt, 1) <> @Char
              set @Pos = @cnt
       set @cnt = @cnt - 1
end

if @Pos = 0
       set @retstring = @String
else
       set @Retstring = left(@String, @Pos)
Return @retstring


END





GO