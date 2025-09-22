IF OBJECT_ID('UDF_RemoveNumbers') IS NOT NULL
BEGIN
Drop FUNCTION UDF_RemoveNumbers
END

GO

SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 

CREATE FUNCTION UDF_RemoveNumbers(@Input VARCHAR(1500)) 
RETURNS VARCHAR(1500)    

---------Examples 
/* 
        select dbo.removenumbers('test3plasdf *-sdf3adf*wor3') 

*/ 

BEGIN 

DECLARE @Length AS INT 
DECLARE @Pos AS INT 
DECLARE @ReturnStr AS VARCHAR(1500) 
DECLARE @KeepChar AS VARCHAR(255) 

SET @length = LEN(@Input) 
SET @Pos = 1 
SET @ReturnStr = '' 
SET @KeepChar = '' 


While @Pos <= @Length 
        BEGIN 
                SET @KeepChar = SUBSTRING(@Input, @Pos, 1) 
                IF @KeepChar LIKE '%[^0-9]%' OR @Keepchar IN (' ') 
                        BEGIN 
                                SET @ReturnStr = @ReturnStr + @KeepChar 
                        END 
                SET @pos = @pos + 1 
        END 
                                
RETURN @ReturnStr 
End
GO