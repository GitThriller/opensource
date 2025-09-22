IF object_id('[dbo].[UDF_RemoveSpecialChars]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_RemoveSpecialChars]
END

GO


/****** Object:  UserDefinedFunction [dbo].[UDF_AlphasOnly]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  function [dbo].[UDF_RemoveSpecialChars](@String as nvarchar(max))
Returns nvarchar(max)
AS
BEGIN
declare @cnt int
declare @RetString nvarchar(max)
set @cnt = 1
set @RetString = ''
if (len(@String) = 0)
       Return ''
while (@cnt <= len(@String))
begin
       IF SUBSTRING(@String, @cnt, 1) LIKE '[0-9a-zA-Z$/%,.() ]'

              set @RetString = @RetString + SubString(@String, @cnt, 1)
       set @cnt = @cnt + 1
end
Return @RetString
END


GO