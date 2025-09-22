
IF OBJECT_ID('UDF_IsInt') IS NOT NULL
BEGIN
	DROP FUNCTION UDF_IsInt
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------
----------------------------------------------------------------
-- Update History:
--	Version 0.1 (150707): Bobby Qiu - Created base script
--	Version 0.2 (160211): Bryan Ye - Updated script with simpler code and more efficient
----------------------------------------------------------------
/*
Script Purpose:
	Purpose of IsInt is like IsNumeric

*/

CREATE FUNCTION UDF_IsInt(@Value NVARCHAR(4000))
RETURNS BIT
AS
BEGIN 
	RETURN CASE WHEN TRY_CAST(@Value AS INT) IS NULL THEN 0 ELSE 1 END 
END 
