IF OBJECT_ID('UDF_OrderedConcat') IS NOT NULL
BEGIN
	DROP AGGREGATE UDF_OrderedConcat
END
GO
CREATE AGGREGATE UDF_OrderedConcat(@order INT,@input NVARCHAR(MAX),@separator NVARCHAR(255))
RETURNS NVARCHAR(MAX)
/*
Aggregate function that concatenates strings with a user defined order and separator, driven by assembly written in C#
This function runs slower than UDF_Concatenate if order is not important.
Note: @order MUST be a unique incrementing sequence starting from one, otherwise below error will occur
Note: @input MUST NOT have any NULL values, otherwise below error will occur

	Msg 6522, Level 16, State 1, Line 170
	A .NET Framework error occurred during execution of user-defined routine or aggregate "UDF_OrderedConcat": 
	System.Collections.Generic.KeyNotFoundException: The given key was not present in the dictionary.
	System.Collections.Generic.KeyNotFoundException: 
	   at System.ThrowHelper.ThrowKeyNotFoundException()
	   at System.Collections.Generic.Dictionary`2.get_Item(TKey key)
	   at UtilClr.OrderedConcat.Terminate()
	.

Created by Bryan Ye 130523
*/
EXTERNAL NAME [UtilClr].[UtilClr.OrderedConcat]
GO