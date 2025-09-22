GO
IF OBJECT_ID('UDF_IntegerOnly') IS NOT NULL 
BEGIN
	DROP FUNCTION UDF_IntegerOnly
END
GO
CREATE FUNCTION UDF_IntegerOnly
/*2 PARAMATERS DEFINED AND THEIR DATATYPE*/
(
	@STRING NVARCHAR(4000)
	,@BLANK_TO_NULL BIT 
)
/*RETURNS DATATYPE*/
/*
This function takes two inputs; (Number, Blank_To_Null)
This function takes a string and removes all characters other than integers
If the value '1' is written in Blank_To_Null, the function converts any blank numbers into Nulls. Otherwise these are left as blanks.
 Examples:
SELECT dbo.UDF_IntegerOnly(475.3839,0) --Returns 4753839
SELECT dbo.UDF_IntegerOnly('1_banana', 0) --Returns 1
SELECT dbo.UDF_IntegerOnly('2017-03-27', 0) --Returns 20170327
SELECT dbo.UDF_IntegerOnly('00057383', 0) --Returns 00057383
SELECT dbo.UDF_IntegerOnly(00057383, 0) --Returns 57383
SELECT DBO.UDF_IntegerOnly('ADFS6ADFD3845.12',0) --RETURNS 6384512
SELECT DBO.UDF_IntegerOnly('ADFS6ADFD3845.12',1) --RETURNS 6384512
SELECT DBO.UDF_IntegerOnly('ABCD',1) --RETURNS NULL
SELECT DBO.UDF_IntegerOnly('ABCD',0) --RETURNS BLANK
*/

RETURNS NVARCHAR(4000)
BEGIN
/*BELOW PATINDEX FUNCTION REMOVES ALL CHARACTERS OTHER THAN INTEGER
FOR EXAMPLE
SELECT PATINDEX('%[^0-9]%','AA') RETURNS 1*/
    WHILE PATINDEX('%[^0-9]%',@STRING) > 0
        SET @STRING = STUFF(@STRING,PATINDEX('%[^0-9]%',@STRING),1,'')

	IF @BLANK_TO_NULL = 1 AND @STRING = ''
	BEGIN
		RETURN NULL 
	END

    RETURN @STRING
END
GO


