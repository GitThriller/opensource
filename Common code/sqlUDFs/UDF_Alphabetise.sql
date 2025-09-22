IF object_id('[dbo].[UDF_Alphabetise]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_Alphabetise]
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION UDF_Alphabetise (@var_text nvarchar(1000)) 
returns nvarchar(1000) 
as 
-- AC: comment
--- This function cleans punctuations from Text String. 
--- Option 0: Replace letters with other letters 
Begin 
declare 
@var_return_text varchar(1000) 

 --   set @var_return_text = replace(dbo.func_clean_punc(@var_text,0),' ','')

    select @var_return_text = ltrim(rtrim(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          @var_text,
                          '0',''),'1',''),'2',''),'3',''),
                          '4',''),'5',''),'6',''),'7',''),
                          '8',''),'9','')))


   return @var_return_text
END
GO