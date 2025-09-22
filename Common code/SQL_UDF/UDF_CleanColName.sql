IF object_id('[dbo].[UDF_CleanColName]') is not NULL
BEGIN
   DROP FUNCTION [dbo].[UDF_CleanColName]
END

GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION UDF_CleanColName(@colname AS VARCHAR(255))
RETURNS VARCHAR(255)
/*
Cleans raw data column names to build work table
Created by Bryan Ye 140408
Updated by Bryan Ye 140415
*/
AS
BEGIN
IF @colname IS NULL
	RETURN NULL 

IF REPLACE(@colname,' ','_') IN
	(
		'Top'
		,'Description'
		,'Type'
		,'Status'
		,'Start_Date'
		,'State'
		,'Text'
		,'Order'
		,'Timestamp'
		,'Page'
		,'Function'
		,'Date'
		,'Address'
		,'Month'
		,'Visiblity'
		,'Version'
		,'USER_ID'
	)
BEGIN
	RETURN REPLACE(@colname,' ','_')+'_'
END

SET @colname = REPLACE(REPLACE(@colname,'%','PCT'),'$','DOL')

WHILE PATINDEX('%[^0-9a-z_]%',@colname) > 0
BEGIN
	SET @colname = STUFF(@colname,PATINDEX('%[^0-9a-z_]%',@colname),1,'_')
END

WHILE CHARINDEX('__',@colname) > 0
BEGIN
	SET @colname = REPLACE(@colname,'__','_')
END

RETURN @colname
END
GO