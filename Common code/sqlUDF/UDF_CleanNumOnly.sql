IF object_id('[dbo].[UDF_CleanNumOnly]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CleanNumOnly]
END

GO

/****** Object:  UserDefinedFunction [dbo].[UDF_CleanNumOnly]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[UDF_CleanNumOnly](@String as nvarchar(255))
       Returns varchar(255)
       AS
       BEGIN
       declare @cnt int
       declare @RetString nvarchar(255)
       DECLARE @has_seen_digit INT 
       set @cnt = 1
       set @RetString = ''
       SET @has_seen_digit =0
       if (len(@String) = 0)
              Return ''
       while (@cnt <= len(@String))
       begin
              if IsNumeric(SubString(@String, @cnt, 1)) = 1 AND
                     SubString(@String, @cnt, 1) <> '-' and
                     SubString(@String, @cnt, 1) <> '+' and
                     SubString(@String, @cnt, 1) <> '.' and
                     SubString(@String, @cnt, 1) <> ','
              BEGIN 
                     IF  NOT ( @has_seen_digit = 0 AND SubString(@String, @cnt, 1) = '0' ) 
                     begin 
                           set @RetString = @RetString + SubString(@String, @cnt, 1)
                     END    
                     
                     IF ( @has_seen_digit = 0 AND SubString(@String, @cnt, 1)  != '0') 
                     BEGIN 
                           SET @has_seen_digit = 1
                     END 
              END    
              set @cnt = @cnt + 1
       end
       Return @RetString
       END


GO
