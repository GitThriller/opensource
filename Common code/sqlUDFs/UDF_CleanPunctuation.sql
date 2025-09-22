IF object_id('[dbo].[UDF_CleanPunctuation]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CleanPunctuation]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_CleanPunctuation]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    function [dbo].[UDF_CleanPunctuation] (@var_text nvarchar(4000), @var_option int)
returns nvarchar(1000)
as
--- This function cleans punctuations from Text String.
--- Option 0: Replace punctuations with Spaces
--- Option 1: Replace punctuations with null
--- Option 2: Replace punctuations with pipe

Begin
declare 
@var_return_text nvarchar(4000)
if isnull(@var_option,1) = 1
   begin
   select @var_option = 1
   end

if @var_option = 1
   begin
   select @var_return_text = ltrim(rtrim(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(
                             replace(replace(replace(replace(replace(replace(
                          replace(
                             @var_text,
                             '(',''),')',''),'[',''),']',''),
                             '{',''),'}',''),':',''),';',''),
                             '"',''),'''',''),'-',''),'_',''),
                             '+',''),'=',''),'|',''),'\',''),
                             '<',''),'>',''),',',''),'.',''),
                             '?',''),'/',''),'*',''),'&',''),
                             '^',''),'%',''),'$',''),'#',''),
                             '~',''),'`',''),'@',''),'!',''),
                             ' ',''),'!',''),'§','')))
   end
else
   begin
   if @var_option = 2
      begin
      select @var_return_text = ltrim(rtrim(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                @var_text,
                                '(','|'),')','|'),'[','|'),']','|'),
                                '{','|'),'}','|'),':','|'),';','|'),
                                '"','|'),'''','|'),'-','|'),'_','|'),
                                '+','|'),'=','|'),'|','|'),'\','|'),
                                '<','|'),'>','|'),',','|'),'.','|'),
                                '?','|'),'/','|'),'*','|'),'&','|'),
                                '^','|'),'%','|'),'$','|'),'#','|'),
                                '~','|'),'`','|'),'@','|'),'!','|')
                               ,' ','|')))
      end
   else
      begin
      select @var_return_text = ltrim(rtrim(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                                replace(replace(replace(replace(replace(replace(
                           replace(replace(replace(
                                @var_text,
                                '(',' '),')',' '),'[',' '),']',' '),
                                '{',' '),'}',' '),':',' '),';',' '),
                                '"',' '),'''',' '),'-',' '),'_',' '),
                                '+',' '),'=',' '),'|',' '),'\',' '),
                                '<',' '),'>',' '),',',' '),'.',' '),
                                '?',' '),'/',' '),'*',' '),'&',' '),
                                '^',' '),'%',' '),'$',' '),'#',' '),
                                '~',' '),'`',' '),'@',' '),'!',' '),
                                '  ',' '),'!',''),'§',''),'¿',' '),
                           'º',' ') ,'ª','')))
      end
   end
return @var_return_text
End



GO