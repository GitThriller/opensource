
----------------------------------------------------------------
-- Code for Grouping similar results
----------------------------------------------------------------

IF OBJECT_ID('tempdb..#results') IS NOT NULL
   DROP TABLE #results

CREATE TABLE #results
(
	Group_ID BIGINT
	,Item_ID BIGINT PRIMARY KEY 
)

----------------------------------------------------------------
--Initiation to run relationship loop
----------------------------------------------------------------

IF OBJECT_ID('tempdb..#relationship_hierarchy') IS NOT NULL
   DROP TABLE #relationship_hierarchy

--Setup table to store results of loop
CREATE TABLE #relationship_hierarchy
(
	Hierarchy INT 
	,Group_ID BIGINT 
	,Item_ID BIGINT 
	PRIMARY KEY 
	(
		Hierarchy
		,Group_ID
		,Item_ID
	)
)

IF OBJECT_ID('tempdb..#new_group') IS NOT NULL
   DROP TABLE #new_group

--Setup table to contain new grouping as intermediate step
CREATE TABLE #new_group
(
	Group_ID BIGINT 
	,Item_ID BIGINT 
	,Num_Groups INT 
	PRIMARY KEY (Group_ID,Item_ID)
)

CREATE INDEX IDX_GRP ON #new_group(Group_ID) INCLUDE(Item_ID,Num_Groups)

----------------------------------------------------------------
--Populate table initially
----------------------------------------------------------------

TRUNCATE TABLE #relationship_hierarchy
INSERT INTO #relationship_hierarchy
SELECT * FROM xxx

----------------------------------------------------------------
--Loop that interatively groups together groups sharing items
----------------------------------------------------------------

--Setup variables
DECLARE @counter INT = 1	--Incrementing counter that tracks level of hierarchy
DECLARE @disp VARCHAR(255)		--Store string display to output status

WHILE EXISTS
(
	--Stop when there are no longer any possible groups
	SELECT Item_ID
	FROM #relationship_hierarchy
	WHERE Hierarchy = @counter
	GROUP BY Item_ID
	HAVING COUNT(DISTINCT Group_ID) > 1
)
--OR @counter < 255
BEGIN
	--Display status
	SET @disp = 'Start '+CAST(@counter AS VARCHAR)+': '+CONVERT(VARCHAR,GETDATE(),20)
	RAISERROR(@disp,0,1) WITH NOWAIT 

	--Insert next level of relationship hierarchy
	TRUNCATE TABLE #new_group
	;WITH items AS
	(
		SELECT Item_ID
			,COUNT(*) num_groups
			--,CHECKSUM(NEWID()) num_groups
		FROM #relationship_hierarchy
		WHERE Hierarchy = @counter
		GROUP BY Item_ID
		HAVING COUNT(*) > 1
	)
	INSERT INTO #new_group
	SELECT rh.Group_ID
		,rh.Item_ID
		,i.num_groups
	FROM #relationship_hierarchy rh
	INNER JOIN items i
		ON i.Item_ID = rh.Item_ID
	WHERE Hierarchy = @counter
	
	INSERT INTO #results
	(
		Group_ID
		,ITEM_ID
	)
	SELECT Group_ID
		,Item_ID
	FROM #relationship_hierarchy rh
	WHERE Hierarchy = @counter
		AND NOT EXISTS 
		(
			SELECT 1 FROM #new_group ng
			WHERE rh.Group_ID = ng.Group_ID
		)

	INSERT INTO #relationship_hierarchy
	SELECT DISTINCT
		@counter+1
		,ca.Item_ID
		,rh.Item_ID
	FROM #relationship_hierarchy rh
	CROSS APPLY
	(
		SELECT TOP 1
			ng.Item_ID
		FROM #new_group ng
		WHERE rh.Group_ID = ng.Group_ID
		ORDER BY ng.num_groups DESC 
			,ng.Item_ID
	) ca
	WHERE rh.Hierarchy = @counter
	
	DELETE FROM #relationship_hierarchy
	WHERE Hierarchy = @counter

	--Increment counter
	SET @counter = @counter + 1
END

--Clear temporary memory
DROP TABLE #new_group

-- Final insert statement for the remaining groups
INSERT INTO #Results
SELECT
	Group_ID
	,Item_ID
FROM #relationship_hierarchy

--Clear temporary memory
DROP TABLE #relationship_hierarchy
