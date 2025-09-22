IF OBJECT_ID('dbo.UDP_StringMatch','P') IS NOT NULL
	DROP PROCEDURE dbo.UDP_StringMatch
GO	

CREATE PROC UDP_StringMatch (
	@ListA_IN StringList READONLY,
	@ListB_IN StringList READONLY
)
AS

IF OBJECT_ID('tempdb..#WEIGHTS','U') IS NOT NULL
	DROP TABLE #WEIGHTS

IF OBJECT_ID('tempdb..#A','U') IS NOT NULL
	DROP TABLE #A

	
IF OBJECT_ID('tempdb..#B','U') IS NOT NULL
	DROP TABLE #B

IF OBJECT_ID('dbo.TEMP_BEST_MATCHES','U') IS NOT NULL
	DROP TABLE dbo.TEMP_BEST_MATCHES

IF OBJECT_ID('dbo.TEMP_ALL_MATCHES','U') IS NOT NULL
	DROP TABLE dbo.TEMP_ALL_MATCHES

DECLARE @ListA StringList;
DECLARE @ListB StringList;

DECLARE @ListA1 StringList;
DECLARE @ListB1 StringList;

INSERT INTO @ListA SELECT ID, dbo.UDF_StringStandardise([Name]) FROM @ListA_IN
INSERT INTO @ListB SELECT ID, dbo.UDF_StringStandardise([Name]) FROM @ListB_IN

INSERT INTO @ListA1 SELECT ID, dbo.UDF_CleanCompanyWords([Name]) FROM @ListA
INSERT INTO @ListB1 SELECT ID, dbo.UDF_CleanCompanyWords([Name]) FROM @ListB

SELECT N.token, COUNT(*) [Count], 1/LOG(COUNT(*)+1,2) [Weight]
INTO #WEIGHTS
FROM (SELECT * FROM @ListA1 UNION SELECT * FROM @ListB1) L
CROSS APPLY dbo.UDF_NGrams(L.[Name],2) N
GROUP BY N.token 
ORDER BY COUNT(*) DESC


SELECT ID, A.token, SUM(W.Weight) [Weight]
INTO #A
FROM @ListA1 L
CROSS APPLY dbo.UDF_NGrams([Name],2) A
INNER JOIN #WEIGHTS W
	ON W.token = A.token
GROUP BY L.ID, A.token
ORDER BY ID DESC

SELECT ID, A.token, SUM(W.Weight) [Weight]
INTO #B
FROM @ListB1 L
CROSS APPLY dbo.UDF_NGrams([Name],2) A
INNER JOIN #WEIGHTS W
	ON W.token = A.token
GROUP BY L.ID, A.token
ORDER BY ID DESC




;WITH norms_A as (
    select ID,
        sum(Weight * Weight) as w2
    from #A
    group by ID
)
,norms_B as (
    select ID,
        sum(Weight * Weight) as w2
    from #B
    group by ID
)
select 
    x.ID as ego,y.ID as v,
	nx.w2 as x2, ny.w2 as y2,
    sum(x.Weight * y.Weight) as innerproduct,
    SUM(x.Weight * y.Weight) / sqrt(nx.w2 * ny.w2) as cosinesimilarity
	INTO #MATCHES
from #A as x
join #B as y
    on (x.token=y.token)
join norms_A as nx
    on (nx.ID=x.ID)
join norms_B as ny
    on (ny.ID=y.ID)
where x.ID <> y.ID
group by x.ID,y.ID,nx.w2,ny.w2
order by 6 desc

--SELECT COUNT(*), COUNT(DISTINCT ego) FROM #MATCHES
--SELECT COUNT(*), COUNT(DISTINCT ego) FROM #MATCHES WHERE cosinesimilarity > 0.9
--SELECT COUNT(*), COUNT(DISTINCT ego) FROM #MATCHES WHERE cosinesimilarity > 0.8
--SELECT COUNT(*), COUNT(DISTINCT ego) FROM #MATCHES WHERE cosinesimilarity > 0.7
--SELECT COUNT(*), COUNT(DISTINCT ego) FROM #MATCHES WHERE cosinesimilarity > 0.6

--SELECT * FROM #MATCHES M 
--INNER JOIN @ListA_IN A
--	ON M.ego = A.ID
--INNER JOIN @ListB_IN B
--	ON M.v = B.ID
--WHERE cosinesimilarity > 0.8

;WITH MX AS (SELECT ego,MAX(Cosinesimilarity) MCS FROM #MATCHES GROUP BY ego)
SELECT M.ego ,
       M.v ,
       A.Name [Ledger_name],
       B.Name [Salesforce_name],
       M.cosinesimilarity
INTO TEMP_BEST_MATCHES
 FROM #MATCHES M 
INNER JOIN @ListA_IN A
	ON M.ego = A.ID
INNER JOIN @ListB_IN B
	ON M.v = B.ID
INNER JOIN MX 
	ON cosinesimilarity = MX.MCS
	AND M.ego = MX.ego
ORDER BY M.cosinesimilarity

SELECT M.ego ,
       M.v ,
       A.Name [Ledger_name],
       B.Name ,
       M.cosinesimilarity
INTO TEMP_ALL_MATCHES
 FROM #MATCHES M 
INNER JOIN @ListA_IN A
	ON M.ego = A.ID
INNER JOIN @ListB_IN B
	ON M.v = B.ID
ORDER BY M.cosinesimilarity


GO