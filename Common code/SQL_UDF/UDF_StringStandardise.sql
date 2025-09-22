IF object_id('[dbo].[UDF_StringStandardise]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_StringStandardise]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_StringStandardise]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE          function [dbo].[UDF_StringStandardise] (@var_text nvarchar(1000)) 
returns nvarchar(1000) 
as
--- This function standardises words from Text String 

Begin 
declare @var_return_text nvarchar(1000) 

-- Replace Known company words 
select @var_return_text = replace(@var_text, '&amp;amp;', '&')
select @var_return_text = replace(@var_return_text, '&amp;#39;', '''')

select @var_return_text = LOWER(@var_return_text)

select @var_return_text = dbo.UDF_Trim(@var_return_text)

   return isnull(@var_return_text,'') 
   end

GO