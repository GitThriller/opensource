IF object_id('[dbo].[UDF_CountCharRepeating]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CountCharRepeating]
END

GO

--Returns the number of digits repeating at the end of an int


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION UDF_CountCharRepeating(@inputSTRING nvarchar(max))
RETURNS INT
AS

begin
DECLARE @STRING NVARCHAR(max)=CONVERT(BIGINT,@inputSTRING)
DECLARE @LEN INT=LEN(@STRING)
DECLARE @COUNTER INT=1
DECLARE @LEN_REPEAT_WORD INT=0
DECLARE @CHAR NVARCHAR(1)=''
DECLARE @REVERSESTRING NVARCHAR(MAX)=REVERSE(@STRING)

IF ISNULL(@inputSTRING,'')=''
RETURN NULL

ELSE
WHILE(@COUNTER<=@LEN)
BEGIN
       IF(@COUNTER=1) 
       SET @CHAR=SUBSTRING(@REVERSESTRING,@COUNTER,1)
       ELSE IF(@CHAR=SUBSTRING(@REVERSESTRING,@COUNTER,1))
       SET @LEN_REPEAT_WORD=@LEN_REPEAT_WORD+1 
       ELSE IF((@CHAR<>SUBSTRING(@REVERSESTRING,@COUNTER,1) AND @LEN_REPEAT_WORD>0))
       SET @COUNTER=@LEN+1 
       ELSE 
       SET @CHAR=SUBSTRING(@REVERSESTRING,@COUNTER,1)
       
SET @COUNTER=@COUNTER+1    

--First loop will define which digit to look for and then move along to the next digit from the end.
--Second loop checks the second last digit equal to the last digit.
--Keep looping until digit does not equal last digit.
       
END
IF(@LEN_REPEAT_WORD>0)
set @LEN_REPEAT_WORD=@LEN_REPEAT_WORD+1
ELSE 
set @LEN_REPEAT_WORD=CASE WHEN @LEN_REPEAT_WORD=0 THEN 1
						ELSE @LEN_REPEAT_WORD
						end

return @LEN_REPEAT_WORD
end



