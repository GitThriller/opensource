IF object_id('[dbo].[UDF_NthChar]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_NthChar]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_NthChar]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE       function [dbo].[UDF_NthChar](@Char as char(1), @String as nvarchar(255), @Instance as smallint)
Returns smallint
AS
BEGIN
/* This function returns the position of the nth occurence of a character*/
declare @pos Int
declare @cnt Int

set @cnt = 0
set @pos = 0

While (@pos < Len(@String) And @cnt <> @Instance)
begin -- Loop
       set @pos = @pos + 1

       if substring(@String, @pos, 1) = @Char
              set @cnt = @cnt + 1
end -- Loop

if @pos = len(@String) 
       set @Pos = 0

Return @pos
END








GO