IF object_id('[dbo].[UDF_CleanLetters]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CleanLetters]
END

GO
/****** Object:  UserDefinedFunction [dbo].[UDF_CleanLetters]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE                        function [dbo].[UDF_CleanLetters] (
@var_text nvarchar(1000)) 
returns nvarchar(1000) 
as
--- This function cleans punctuations from Text String. 
--- Option 0: Replace letters with other letters 


Begin 
declare 
@var_return_text nvarchar(1000) 

set @var_return_text = @var_text
    -- replace double letters
    select @var_return_text = ltrim(rtrim(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          replace(replace(replace(replace(
                          @var_return_text,
                          'aa','a'),'bb','b'),'cc','c'),'dd','d'),
                          'ee','e'),'ff','e'),'gg','g'),'hh','h'),
                          'ii','i'),'jj','j'),'kk','k'),'ll','l'),
                          'mm','m'),'nn','n'),'oo','o'),'pp','p'),
                          'qq','q'),'rr','r'),'ss','s'),'tt','t'),
                          'uu','u'),'vv','v'),'ww','w'),'xx','x'),
                          'yy','y'),'zz','z')))
      -- Replace Known phonetic 
      
      select @var_return_text = replace(@var_return_text,'PH','F') 
      select @var_return_text = replace(@var_return_text,'PF','F') 
      select @var_return_text = replace(@var_return_text,'SZ','S') 
      select @var_return_text = replace(@var_return_text,'CSH','SH')
      select @var_return_text = replace(@var_return_text,'SCH','SH')
      select @var_return_text = replace(@var_return_text,'CH','SH')
      select @var_return_text = replace(@var_return_text,'MB','M')
      select @var_return_text = replace(@var_return_text,'SC','S') 
      select @var_return_text = replace(@var_return_text,'CS','S') 
      select @var_return_text = replace(@var_return_text,'CZ','S') 
      select @var_return_text = replace(@var_return_text,'ZC','S') 
      select @var_return_text = replace(@var_return_text,'ZS','S') 
      select @var_return_text = replace(@var_return_text,'TS','S') 
      select @var_return_text = replace(@var_return_text,'ST','S') 
      select @var_return_text = replace(@var_return_text,'QU','CU') 
      select @var_return_text = replace(@var_return_text,'Y','I') 
      select @var_return_text = replace(@var_return_text,'J','I') 
      select @var_return_text = replace(@var_return_text,'Z','S') 
      select @var_return_text = replace(@var_return_text,'X','S') 
      select @var_return_text = replace(@var_return_text,'K','C') 
      select @var_return_text = replace(@var_return_text,'F','V') 
      select @var_return_text = replace(@var_return_text,'V','W') 
   return @var_return_text
   end



GO