/*
Author: Eitan Blumin (t: @EitanBlumin | b: https://eitanblumin.com)
Date Created: 2013-09-01
Last Update: 2020-06-23
Description:
Table Function to generate periods for time series
*/
CREATE OR ALTER FUNCTION [dbo].[GeneratePeriods]
(
	@EndDate DATETIME,
	@PeriodType CHAR(2),
	@NumOfPeriodsBack INT
)
RETURNS TABLE
AS RETURN
(
	WITH FirstPeriod
	AS
	(
		SELECT 
			StartDate =
				CASE @PeriodType
					WHEN 'W' THEN
						DATEADD(day,-1,DATEADD(ww,DATEDIFF(ww,0,@EndDate),0))
					WHEN 'M' THEN
						DATEADD(mm,DATEDIFF(mm,0,@EndDate),0)
					WHEN 'Q' THEN
						DATEADD(Q,DATEDIFF(Q,0,@EndDate),0)
					WHEN 'T' THEN
						CASE
							WHEN DATEPART(mm,@EndDate) >= 9 THEN DATEADD(mm,8,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
							WHEN DATEPART(mm,@EndDate) >= 5 THEN DATEADD(mm,4,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
							ELSE DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0)
						END
					WHEN 'HY' THEN
						CASE WHEN DATEPART(mm,@EndDate) >= 7 THEN DATEADD(mm,6,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
						ELSE DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0)
						END
					WHEN 'Y' THEN
						DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0)
				END,
			EndDate =
				CASE @PeriodType
					WHEN 'W' THEN
						DATEADD(day,-1,DATEADD(ww,DATEDIFF(ww,0,@EndDate)+1,0))
					WHEN 'M' THEN
						DATEADD(mm,DATEDIFF(mm,0,@EndDate)+1,0)
					WHEN 'Q' THEN
						DATEADD(Q,DATEDIFF(Q,0,@EndDate)+1,0)
					WHEN 'T' THEN
						DATEADD(mm,4,
							CASE
								WHEN DATEPART(mm,@EndDate) >= 9 THEN DATEADD(mm,8,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
								WHEN DATEPART(mm,@EndDate) >= 5 THEN DATEADD(mm,4,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
								ELSE DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0)
							END)
					WHEN 'HY' THEN
						CASE WHEN DATEPART(mm,@EndDate) >= 7 THEN DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate)+1,0)
						ELSE DATEADD(mm,6,DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate),0))
						END
					WHEN 'Y' THEN
						DATEADD(yyyy,DATEDIFF(yyyy,0,@EndDate)+1,0)
				END
	), Periods
	AS
	(
		SELECT 
			PeriodNum = 1,
			StartDate,
			EndDate = DATEADD(dd,1,EndDate)
		FROM FirstPeriod
		
		UNION ALL
		
		SELECT
			PeriodNum = PeriodNum + 1,
			StartDate = 
				CASE @PeriodType
					WHEN 'W' THEN
						DATEADD(ww,-1,StartDate)
					WHEN 'M' THEN
						DATEADD(mm,-1,StartDate)
					WHEN 'Q' THEN
						DATEADD(Q,-1,StartDate)
					WHEN 'T' THEN
						DATEADD(mm,-4,StartDate)
					WHEN 'HY' THEN
						DATEADD(mm,-6,StartDate)
					WHEN 'Y' THEN
						DATEADD(yyyy,-1,StartDate)
				END,
			EndDate = DATEADD(dd,1,StartDate)
		FROM
			Periods
		WHERE
			PeriodNum < @NumOfPeriodsBack
	)
	SELECT *
	FROM Periods
)

