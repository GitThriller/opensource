SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------
--Create procedure

CREATE OR ALTER PROC [dbo].[RunDataChecks]
	@JournalTable NVARCHAR(MAX),
	@StartDate DATE,
	@EndDate DATE,
	@ForeignCurrency BIT = 0
AS
BEGIN

-----------------------------------------------------------
--Begin

    DECLARE @SQL NVARCHAR(MAX);

    --Net to zero check
    SET @SQL
		= N'SELECT ''Net to zero check'' AS Test, SUM(CAST([Amount] AS MONEY)) FROM ' + @JournalTable;

    EXEC sp_executesql @SQL;


    --Do not net to zero - Journal ID level
    SET @SQL
		= N'SELECT ''Do not net to zero - Journal ID level'' AS Test, [Journal ID], SUM(CAST([Amount] AS MONEY)) FROM ' + @JournalTable
		+ N' GROUP BY [Journal ID]
		HAVING ABS(SUM(CAST([Amount] AS MONEY))) >0.001';

    EXEC sp_executesql @SQL;


    --Do not net to zero - Journal ID level, line details
    SET @SQL
		= N'SELECT ''Do not net to zero - Journal ID level, line details'' AS Test, * FROM' + @JournalTable
		+ N' WHERE [Journal ID] in (SELECT [Journal ID] FROM ' + @JournalTable
									+ N' GROUP BY [Journal ID]
									HAVING ABS(SUM(CAST([Amount] AS MONEY))) >0.001)'

    EXEC sp_executesql @SQL;


    --Not within date range --POSSIBLE ERROR
	SET @SQL
        = N'SELECT ''Not within date range'' AS Test, * FROM ' + @JournalTable
		+ N' WHERE [Date effective] NOT BETWEEN ''' + CONVERT(NVARCHAR, @StartDate) + N''' AND ''' + CONVERT(NVARCHAR, @EndDate) + N'''';

    EXEC sp_executesql @SQL;


	--Multiple date effectives for one Journal ID
	SET @SQL
		= N'SELECT ''Multiple date effectives'' AS Test, * FROM' + @JournalTable
		+ N' WHERE [Journal ID] in (SELECT [Journal ID] FROM ' + @JournalTable
									+ N' GROUP BY [Journal ID]
									HAVING COUNT(DISTINCT [Date effective])>1)'
    EXEC sp_executesql @SQL;


	--Multiple date posted for one Journal ID
	SET @SQL
		= N'SELECT ''Multiple date posteds'' AS Test, * FROM' + @JournalTable
		+ N' WHERE [Journal ID] in (SELECT [Journal ID] FROM ' + @JournalTable
									+ N' GROUP BY [Journal ID]
									HAVING COUNT(DISTINCT [Date posted])>1)'
    EXEC sp_executesql @SQL;


	--Multiple document types for one Journal ID
	SET @SQL
		= N'SELECT ''Multiple document types'' AS Test, * FROM' + @JournalTable
		+ N' WHERE [Journal ID] in (SELECT [Journal ID] FROM ' + @JournalTable
									+ N' GROUP BY [Journal ID]
									HAVING COUNT(DISTINCT [Document type])>1)'
    EXEC sp_executesql @SQL;


	--Multiple posting users for one Journal ID
	SET @SQL
		= N'SELECT ''Multiple posting users'' AS Test, * FROM' + @JournalTable
		+ N' WHERE [Journal ID] in (SELECT [Journal ID] FROM ' + @JournalTable
									+ N' GROUP BY [Journal ID]
									HAVING COUNT(DISTINCT [Posting user])>1)'
    EXEC sp_executesql @SQL;


    --Data not unique on Journal ID and line number
    SET @SQL
		= N'SELECT ''Data not unique on Journal ID and line number'' AS Test, [Journal ID], [Journal line number], COUNT(*) FROM ' + @JournalTable
		+ N' GROUP BY [Journal ID], [Journal line number]
		HAVING COUNT(*) > 1';

    EXEC sp_executesql @SQL;


	--Quotation marks found within text fields
	SET @SQL
		= N'SELECT ''Quotation marks found within text fields'' AS Test, * FROM '+ @JournalTable
		+ N' WHERE [Journal description] LIKE ''%"%''';

    EXEC sp_executesql @SQL;


	--Foreign currency checks
    IF (@ForeignCurrency = 1)
    BEGIN
    
		--Net to zero check
        SET @SQL
            = N'SELECT ''Foreign currency: Net to zero check'' AS Test, SUM(CONVERT(MONEY,[Foreign currency amount])) FROM ' + @JournalTable;

        EXEC sp_executesql @SQL;

        --Do not net to zero - Journal ID level
        SET @SQL
            = N'SELECT ''Foreign currency: Do not net to zero - Journal ID level'' AS Test, [Journal ID], SUM(CONVERT(MONEY,[Foreign currency amount])) FROM ' + @JournalTable
            + N' GROUP BY [Journal ID]
			HAVING ABS(SUM(CONVERT(MONEY,[Foreign currency amount]))) >0.001';

		PRINT (@SQL)

        EXEC sp_executesql @SQL;
    END;

END;
