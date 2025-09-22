IF object_id('[dbo].[UDF_SpaceBeforeCap]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_SpaceBeforeCap]
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Leo Hua
-- function created to insert space before every Cap letter
CREATE FUNCTION UDF_SpaceBeforeCap
(
 @str nvarchar(max)
)
returns nvarchar(max)
as
begin

declare @i int, @j int
declare @returnval nvarchar(max)
set @returnval = ''
select @i = 1, @j = len(@str)

declare @w nvarchar(max)

while @i <= @j
begin
 if substring(@str,@i,1) = UPPER(substring(@str,@i,1)) collate Latin1_General_CS_AS
 begin
  if @w is not null
  set @returnval = @returnval + ' ' + @w
  set @w = substring(@str,@i,1)
 end
 else
  set @w = @w + substring(@str,@i,1)
 set @i = @i + 1
end
if @w is not null
 set @returnval = @returnval + ' ' + @w

return ltrim(@returnval)

END
GO