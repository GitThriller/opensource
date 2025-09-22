IF object_id('[dbo].[UDF_FUNC_TRIM]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_FUNC_TRIM]
END

GO

/****** Object:  UserDefinedFunction [dbo].[FUNC_TRIM]    Script Date: 21/05/2014 4:44:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    function [dbo].[UDF_FUNC_TRIM](@String as varchar(255))
Returns varchar(255)
AS
BEGIN
/* This function removes all multi spaces in the string and replaces them with a single space and removes
leading or trailing spaces.
EG 
   Mick      Power    .
becomes
Mick Power .
*/

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

declare @AString varchar(255)
declare @RetString varchar(255)
set @String = Ltrim(Rtrim(@String))
set @String = Replace(@String, '  ', ' ')
while (Charindex('  ', @String, 1) <> 0)
begin
set @String = Replace(@String, '  ', ' ')
end
set @RetString = @String
Return @RetString
end

GO
