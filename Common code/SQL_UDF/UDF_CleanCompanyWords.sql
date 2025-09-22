IF object_id('[dbo].[UDF_CleanCompanyWords]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CleanCompanyWords]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_CleanCompanyWords]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE          function [dbo].[UDF_CleanCompanyWords] (@var_text nvarchar(1000)) 
returns nvarchar(1000) 
as
--- This function cleans street words from Text String an replaces them with a 
-- space or relevant abbreviation

Begin 
declare @var_return_text nvarchar(1000) 


-- Replace Known company words 

select @var_return_text = replace (@var_text, ' CO ', ' ')
select @var_return_text = replace (@var_return_text, ' ASSOCIATION ', ' ')
select @var_return_text = replace (@var_return_text, ' ASSOCIATES ', ' ')
select @var_return_text = replace (@var_return_text, ' PTY ', ' ')
select @var_return_text = replace (@var_return_text, ' PL', ' ')
select @var_return_text = replace (@var_return_text, ' LTD ', ' ')
select @var_return_text = replace (@var_return_text, ' LTD', ' ')
select @var_return_text = replace (@var_return_text, ' LIMITED', ' ')
select @var_return_text = replace (@var_return_text, ' PROPRIETRY ', ' ')
select @var_return_text = replace (@var_return_text, ' LIMITED ', ' ')
select @var_return_text = replace (@var_return_text, ' GROUP ', ' ')
select @var_return_text = replace (@var_return_text, ' ASSOC ', ' ')
select @var_return_text = replace (@var_return_text, ' AND ', ' ')
select @var_return_text = replace (@var_return_text, ' THE ', ' ')
select @var_return_text = replace (@var_return_text, ' OF ', ' ')
select @var_return_text = replace (@var_return_text, ' SERVICE ', ' ')
select @var_return_text = replace (@var_return_text, ' SERVICES ', ' ')
select @var_return_text = replace (@var_return_text, ' AUSTRALIAN ', ' ')  
select @var_return_text = replace (@var_return_text, ' AUSTRALIA ', ' ')
select @var_return_text = replace (@var_return_text, ' AUST ', ' ')
select @var_return_text = replace (@var_return_text, ' AUS ', ' ')
select @var_return_text = replace (@var_return_text, ' COMPANY ', ' ')
select @var_return_text = replace (@var_return_text, ' CENTRE ', ' ')
select @var_return_text = replace (@var_return_text, ' CENTER ', ' ')
select @var_return_text = replace (@var_return_text, ' SOLICITOR ', ' ')
select @var_return_text = replace (@var_return_text, ' SOLICITORS ', ' ')
select @var_return_text = replace (@var_return_text, ' ATTORNEY ', ' ')
select @var_return_text = replace (@var_return_text, ' ATTORNEYS ', ' ')
select @var_return_text = replace (@var_return_text, ' DR ', ' ')
select @var_return_text = replace (@var_return_text, ' US ', ' ')
select @var_return_text = replace (@var_return_text, ' NZ ', ' ')
select @var_return_text = replace (@var_return_text, ' P L ', ' ')
select @var_return_text = replace (@var_return_text, ' DEPT ', ' ')
select @var_return_text = replace (@var_return_text, ' DEPARTMENT ', ' ')
select @var_return_text = replace (@var_return_text, ' DO NOT USE ', ' ')
select @var_return_text = replace (@var_return_text, ' DONT USE ', ' ')
select @var_return_text = replace (@var_return_text, ' DONOT USE ', ' ')
select @var_return_text = replace (@var_return_text, ' DON NOT USE ', ' ')
select @var_return_text = replace (@var_return_text, ' USE OTHER ', ' ')
select @var_return_text = replace (@var_return_text, ' USE ONLY ', ' ')
select @var_return_text = replace (@var_return_text, ' USE ', ' ')
select @var_return_text = replace (@var_return_text, ' CLOSED ', ' ')
select @var_return_text = replace (@var_return_text, ' International ', ' ')
select @var_return_text = replace (@var_return_text, ' Dist ', ' ')
select @var_return_text = replace (@var_return_text, ' Trustee ', ' ')
select @var_return_text = replace (@var_return_text, ' Trust ', ' ')
select @var_return_text = replace (@var_return_text, ' Fund ', ' ')
select @var_return_text = replace (@var_return_text, ' ABN ', ' ')
select @var_return_text = replace (@var_return_text, ' HOLDING ', ' ')
select @var_return_text = replace (@var_return_text, ' HOLDINGS ', ' ')
select @var_return_text = replace (@var_return_text, ' GMBH ', ' ')
select @var_return_text = replace (@var_return_text, ' GNBH ', ' ')
select @var_return_text = replace (@var_return_text, ' INC ', ' ')
select @var_return_text = replace (@var_return_text, ' INCORPORATED ', ' ')
select @var_return_text = replace (@var_return_text, ' S A ', ' ')
select @var_return_text = replace (@var_return_text, ' DELETED ', ' ')

   return isnull(@var_return_text,'') 
   end

GO