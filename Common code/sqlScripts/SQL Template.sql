======================================================================================
======================================================================================
Creating Procs in general

CREATE TABLE <table name>
(

UNIQUE (<column 1>, <column 2>)
)

INSERT INTO <table name>
(

)

SELECT
<column 1>
,<column 2>
…
FROM <source table name>
======================================================================================
======================================================================================
Create PROC -- use snippet 'cpd'


======================================================================================
======================================================================================
Creating PROC Header (use the standard snippet “header” to generate the template)

CREATE PROC BLD_WRK_[Description]_YYMMDD_XX
AS

-------------------------------------------------------
-------------------------------------------------------

/*
Update History:
Version 0.1 (YYMMDD): {author} : {Description}
Version 0.2 (YYMMDD): {author} : {Description}

-------------------------------------------------------

Script Purpose:
{Description}

Input Table(s):
SELECT TOP 100 * FROM {input_table}

Output Table(s):
SELECT TOP 100 * FROM {output_table}

*/

-------------------------------------------------------
-- PARAMETER DECLARATION
-------------------------------------------------------

DECLARE @PERIOD_CUTOFF DATETIME
SET @PERIOD_CUTOFF = ''

-------------------------------------------------------
======================================================================================
======================================================================================
-------------------------------------------------------
--	DROP TABLE SECTION
-------------------------------------------------------



-------------------------------------------------------
--	CREATE TABLE SECTION
-------------------------------------------------------
CREATE TABLE WRK_[Description] (
	 ID INT
	,FULL_NAME VARCHAR(255)
	,CITY VARCHAR(255)
	,COUNTRY VARCHAR(255)
	,TOTAL_PAYSLIP_AMOUNT FLOAT
)

-- another example with CHECK()
CREATE TABLE WRK_PAYROLL_TRANSACTIONS
(
	Employee_ID INT CHECK(LEN(Employee_ID) = 5) NOT NULL
	,Recruiter_ID INT CHECK(LEN(Recruiter_ID) = 5)
	,Division VARCHAR(255)
	,Transaction_Date DATE CHECK(Transaction_Date BETWEEN '2011-07-01' AND '2012-06-30')
	,Transaction_Type VARCHAR(255)
	,Amount FLOAT
	UNIQUE(Employee_ID,Transaction_Date,Transaction_Type)
)


-------------------------------------------------------
--	INSERT TABLE SECTION
-------------------------------------------------------
INSERT INTO WRK_[Description]


-- CTE
;With avg_payslip AS (
   SELECT Employee_ID,AVG(Payslip_Amount) as AVG_Payslip
   FROM WRK_Employee_Payslips
   GROUP BY Employee_ID
)


SELECT
    PSY.ID
   ,EMP.FIRST_NAME+' '+ EMP.LAST_NAME AS FULL_NAME
   ,EMP.CITY
   ,EMP.COUNTRY
   ,SUM(TOTAL_PAYSLIP_AMOUNT) AS TOTAL_PAYSLIP_AMOUNT
   ,avg_payslip.AVG_Payslip
FROM
    WRK_PSY_EMPLOYEE_PAYSLIP PSY
LEFT JOIN 
    EMPLOYEE_DETAILS EMP
ON  EMP.ID = EMP.ID
INNER JOIN avg_payslip
ON WRK.Employee_ID = avg_payslip.Employee_ID
GROUP BY	
    PSY.ID
   ,EMP.FIRST_NAME+' '+ EMP.LAST_NAME
   ,EMP.CITY
   ,EMP.COUNTRY
--(xxx row(s) affected) YYMMDD
======================================================================================
======================================================================================
-- Create UDF

CREATE FUNCTION [dbo].[Replace_Character_Set]
(
	@String VARCHAR(1000)
	,@Replace VARCHAR(1000)
	,@ReplaceWith VARCHAR(1000)
)

RETURNS VARCHAR(1000)

AS
BEGIN 
 
    WHILE PatIndex('%' + @Replace + '%', @String) > 0 
        SET @String = Stuff(@String, PatIndex('%' + @Replace + '%', @String), 1, @ReplaceWith) 
 
    RETURN @String

END 
======================================================================================
======================================================================================
-- Variable

DECLARE @variable NVARCHAR(400)

SELECT @variable='hello'

-- change
SET @variable='olleh'

======================================================================================
======================================================================================
-- Table Variable

DECLARE @table AS TABLE (
      Invoice_Date Date
     ,Payment_Date DATE
     ,Invoice_Number BIGINT
)

INSERT INTO @table 
Values (‘2013-01-01’,’2013-01-05’,12345)

Select * from @table
======================================================================================
======================================================================================
Window functions
Window functions are a type of ‘set function’. This means they are applied over a set of rows.
The ‘window’ refers to the set of rows over which you are applying the function

--
ROW_NUMBER()
Assign a sequential row number [1,2,3..N] to each row of the returned set

Usage: ROW_NUMBER() over (ORDER BY <Order by columns>)

--
RANK()
RANK () over (ORDER BY <Order by columns>)

--
DENSE_RANK()
DENSE_RANK () over (ORDER BY <Order by columns>)

--
PARTITION BY:
Divide the returned set into different groups
Can be used with ROW_NUMBER(), RANK(), DENSE_RANK()

Usage: 

ROW_NUMBER() over (PARTITION BY <Group column> ORDER BY <Order by Column>)

RANK() over (PARTITION BY <Group column> ORDER BY <Order by Column>)

DENSE_RANK() over (PARTITION BY <Group column> ORDER BY <Order by Column>)

--
You can also apply system aggregate function as window functions
Example:
COUNT() OVER (PARTITION BY [Service Line]) as CNT
MAX([Employee ID]) OVER (PARTITION BY [Service Line]) as Max_Emp

the following common pitfalls of window function:
these window functions are applied before DISTINCT
if your table contains duplicates, make sure you remove the duplicates before you apply the window function


Question:
For each provider in [WRK_CLAIM_LINE], list the top 5 service dates with the most service amount. If there are dates with the same service amount, order them by date. 

Answer:
SELECT * FROM
(
	SELECT
		PROVIDER
		,DATE
		,SUM(AMOUNT)
		,ROW_NUMBER() PARTITION BY(PROVIDER) ORDER BY (SUM(AMOUNT) DESC, DATE) RN
	FROM TABLE_NAME
	GROUP BY
		PROVIDER
		,DATE
) X
WHERE RN<=5
ORDER BY PROVIDER, RN

======================================================================================
======================================================================================
-- INDEX

-- retrieves a range of data
CREATE CLUSTERED INDEX IDX_SALARY ON EMPLOYEE_MASTER(EMPLOYEE_ID)

SELECT em.EMPLOYEE_ID 
FROM EMPLOYEE_MASTER em
WHERE em.EMPLOYEE_ID BETWEEN ‘1000’ AND ‘5000’


-- retrieve a small number of rows from a large table
CREATE NONCLUSTERED INDEX IDX_SALARY ON EMPLOYEE_MASTER(EMPLOYEE_ID)

SELECT em.EMPLOYEE_ID 
FROM EMPLOYEE_MASTER em
WHERE em.EMPLOYEE_ID = ‘123’


-- multiple nonclustered index
CREATE NONCLUSTERED INDEX IDX_SALARY ON EMPLOYEE_MASTER(EMPLOYEE_ID)
INCLUDE(EMPLOYEE_NAME,SALARY)

CREATE NONCLUSTERED INDEX IDX_LEVEL ON EMPLOYEE_LEVEL(EMPLOYEE_ID)
INCLUDE(JOB_LEVEL)

SELECT em.EMPLOYEE_NAME
      ,el.JOB_LEVEL
      ,em.SALARY
FROM EMPLOYEE_MASTER em
INNER JOIN EMPLOYEE_LEVEL el 
    ON em.EMPLOYEE_ID = el.EMPLOYEE_ID
======================================================================================
======================================================================================
-- CROSS APPLY, OUTER APPLY
The apply operator is used to effectively utilise table based calculations upon a query. This can be especially useful when looking for ‘most recent’ or ‘highest value’ invoices

--
SELECT
 [cus].[Customer_ID] ,[inv].[Invoice_Date] ,[inv].[Invoice_Amount]
FROM Customer_Master cus
CROSS APPLY
 (
 SELECT TOP 1 *
 FROM [Customer_Invoices] inv
 WHERE [cus].[Customer_ID] = [inv].[Customer_ID]
 ORDER BY
 [Invoice_Date] DESC
 ) 


--
SELECT * FROM [Employee_Master] 
CROSS APPLY REF_PAYSLIP_ITEMS


-- serves much like a LEFT JOIN in that it returns all values from the left hand side table
SELECT
 [cus].[Customer_ID] ,[inv].[Invoice_Date] ,[inv].[Invoice_Amount]
FROM Customer_Master cus
OUTER APPLY
 (
 SELECT TOP 1 *
 FROM [Customer_Invoices] inv
 WHERE [cus].[Customer_ID] = [inv].[Customer_ID]
 ORDER BY
 [Invoice_Date] DESC
 ) 
======================================================================================
======================================================================================
-- IN
SELECT title 
FROM titles
WHERE pub_id IN (SELECT pub_id 
	        FROM publishers 
	        WHERE city LIKE 'B%')

-- EXIST
SELECT title 
FROM titles as t
WHERE EXISTS (SELECT * 
	     FROM publishers 
	     WHERE pub_id = t.pub_id 
	     AND city LIKE 'B%')


Large dataset – use ‘EXISTS’. ‘IN’ has a tendency to generate execution plans that evaluate every single value before deciding true or false, EXISTS evaluates until the first true result then stops independent of the complexity.
Small dataset – can use ‘IN’ as it is more efficient (to code)
Multiple fields – if you are using multiple fields in the criteria use ‘EXISTS’ (rather than ‘IN’ with concatenation). 
NULLs in the list – IN will fail if there is NULL in the IN list
======================================================================================
======================================================================================
-- JOIN

Filter Conditions on OUTER JOINS
WHERE clauses are evaluated after the join; therefore a condition in the ON clause could produce different results

meaning

SELECT * FROM Customer
LEFT JOIN Orders 
     ON Customer.CustomerID = Orders.Customer_ID
WHERE
     Orders.OrderAmt > 5 -- return 2 results, join first and then filter

is different from

SELECT * FROM Customer
LEFT JOIN Orders 
     ON Customer.CustomerID = Orders.Customer_ID AND Orders.OrderAmt > 5
     -- filter first and then join, so more records found with nulls
======================================================================================
======================================================================================
-- Multiple joins
SELECT
*
FROM
     WRK_Salary Salary
FULL JOIN WRK_BONUS Bonus
     ON Salary.Employee_ID = Bonus.Employee_ID
FULL JOIN WRK_ALLOWANCE Allowance
     ON Salary.Employee_ID = Allowance.Employee_ID


ON Salary.Employee_ID = Allowance.Employee_ID OR Bonus.Employee_ID = Allowance.Employee_ID (not good)

ON COALESCE(Salary.Employee_ID, Bonus.Employee_ID) = Allowance.Employee_ID (ideal)
======================================================================================
======================================================================================
-- Information Schema

SELECT * FROM INFORMATION_SCHEMA.TABLES


SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'table_name'
AND COLUMN_NAME = 'field_name'

-- contains the list of procedures and functions within the active database
SELECT * FROM INFORMATION_SCHEMA.ROUTINES

INFORMATION_SCHEMA.VIEWS
======================================================================================
======================================================================================
-- sys.objects, sys.schemas, sys.columns

======================================================================================
======================================================================================
-- String manipulation

-- [A-Za-z], [^0-9A-Za-z]
SELECT Field_Name LIKE ‘%[A-Za-z]%' will match “9322a7000” 
SELECT Field_Name LIKE '%[^0-9A-Za-z]%' will match “+61293227000”

-- PATINDEX / CHARINDEX

-- REPLACE / STUFF

-- DATEDIFF
Year: first day of the year, i.e. DATEDIFF(YY,’2012-12-31’,’2013-01-01’) = 1
Month: first day of the month , i.e. DATEDIFF (MM,’2012-11-30’,’2012-12-01’) = 1

If a proportion of the day is required, divide as follows: 
  DATEDIFF(MI,'2012-11-30 23:59:59','2012-12-01 00:00:01') / 60.0 / 24.0

To get the last day of any month, use
  DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,'1900-01-01',<DATE>)+1,'1900-01-01'))

To get a character string representation of the date part, e.g. the weekday of the date, use the DATENAME function
e.g. DATENAME (dw, '2013-03-13') returns “Wednesday”


======================================================================================
======================================================================================



======================================================================================
======================================================================================
[HOLIDAY_DATE_ID] INT NOT NULL PRIMARY KEY,

WHERE ISNULL(ACCOUNT_DESCRIPTION_KEY_WORD,'')<>''