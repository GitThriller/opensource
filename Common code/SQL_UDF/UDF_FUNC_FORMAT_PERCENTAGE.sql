IF object_id('[dbo].[UDF_FUNC_FORMAT_PERCENTAGE]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_FUNC_FORMAT_PERCENTAGE]
END

GO

/****** Object:  UserDefinedFunction [dbo].[FUNC_FORMAT_PERCENTAGE]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UDF_FUNC_FORMAT_PERCENTAGE] (
@NUMERIC DOUBLE PRECISION,
@ROUNDING INT = 2
) 
RETURNS NVARCHAR(50)
AS
BEGIN

          /*********************************************************************************/
          /*********************************************************************************/
          /**                                                                             **/
          /**                   I M P O R T A N T   D I S C L A I M E R                   **/
          /**                                                                             **/
          /**     These stored procedures, functions, assemblies and general working      **/
          /**     files (Materials) remain the property of the Australian firm of         **/
          /**     Deloitte Touche Tohmatsu (Deloitte Australia).  Deloitte Australia      **/
          /**     has agreed that certain other member firms of Deloitte Touche Tohmatsu  **/
          /**     Limited may have a limited, non-exclusive, revocable, non-transferable  **/
          /**     licence to access the Materials subject to the following:               **/
          /**                                                                             **/
          /**     -     the content of the Materials must not be copied, modified,        **/
          /**     reverse engineered, disassembled, decompiled, used or disclosed to      **/
          /**     any third party without the prior written consent of Deloitte           **/
          /**     Australia; and                                                          **/
          /**     -     the Materials must only be accessed and used by personnel who     **/
          /**     have received appropriate training.                                     **/
          /**                                                                             **/
          /**     To the extent permitted by law, Deloitte Australia accepts no           **/ 
          /**     liability for any loss or damage caused by the use of the Materials.    **/
          /**     Deloitte Australia is not responsible for providing error correction,   **/
          /**     maintenance, enhancements or support services in connection with the    **/
          /**     Materials.                                                              **/
          /**                                                                             **/
          /*********************************************************************************/
          /*********************************************************************************/

declare @return_value NVARCHAR(50)
declare @is_negative bit
select @is_negative = case when @NUMERIC < 0 then 1 else 0 end
if @is_negative = 1
set @NUMERIC = -1.0 * @NUMERIC
set @return_value = ltrim(str(isnull(@NUMERIC, 0) * 100, 40, @rounding))
DECLARE @before NVARCHAR(50)
DECLARE @after NVARCHAR(50)
if charindex ('.', @return_value )>0 
begin
set @after = substring(@return_value,  charindex ('.', @return_value ) + 1, len(@return_value) - charindex ('.', @return_value ))
set @before = substring(@return_value, 1,  charindex ('.', @return_value )-1)
end
else
begin
set @before = @return_value
set @after=''
end
-- after every third character:
declare @i int
if len(@before)>3 
begin
set @i = 3
while @i>1 and @i < len(@before)
begin
set @before = substring(@before,1,len(@before)-@i) + ',' + right(@before,@i)
set @i = @i + 4
end
end
declare @cnt int
declare @Pos int
declare @retstring varchar(255)
set @cnt = len(@AFTER)
set @retstring = ''
set @Pos = 0
-- Get position of last character that is not @Char
while (@cnt >= 1 and @Pos = 0)
begin
if Substring(@AFTER, @cnt, 1) <> '0'
set @Pos = @cnt
set @cnt = @cnt - 1
end
if @Pos <> 0
set @AFTER = left(@AFTER, @Pos)
IF CONVERT(INT, @AFTER) = 0 
set @return_value = @before + '%'
ELSE 
set @return_value = @before + '.' + @after + '%'
if @is_negative = 1
set @return_value = '-' + @return_value
return @return_value 
END
GO