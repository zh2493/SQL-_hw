USE covid;

/*1. 64 counties are reported in the dataset*/
SELECT COUNT(DISTINCT(admin2)) AS country_num
FROM confirmed;

/*2. Hamilton, Out of NY and Unassigned reporting less than 1000 confirmed cases as of 11/29/21. 
Hamilton has 512 cases, Out of NY has 0, Unassignedhas 141. */
SELECT admin2 AS county_name, confirmed_cases
FROM confirmed
WHERE confirmed_cases <1000 AND confirm_date = "2021-11-29";

/*3. 64 counties are reported in the dataset*/
SELECT admin2 AS county_name, confirm_date, confirmed_cases,
DENSE_RANK() OVER(ORDER BY confirmed_cases) AS country_rank
FROM confirmed
WHERE confirm_date = "2021-11-29";

/*4.  the average number of confirmed cases in the bottom 10 is 200840.3000 and the 
conties have Kings, Queens, Suffolk, Nassau, Bronx, New York
Westchester, Erie, Monroe, Richmond*/
WITH bottom_ten AS
(
WITH bottom_ten_1 AS
(
SELECT admin2 AS county_name, confirm_date, confirmed_cases,
DENSE_RANK() OVER(ORDER BY confirmed_cases) AS county_rank
FROM confirmed
WHERE confirm_date = "2021-11-29"
)
SELECT *
FROM bottom_ten_1
ORDER BY county_rank DESC
LIMIT 10
)
 SELECT *, AVG(confirmed_cases) OVER() AS bottom_ten_avg
 FROM bottom_ten;

/*5. */
CREATE TEMPORARY TABLE top_counties AS
(SELECT admin2 AS county_name, confirm_date, confirmed_cases,
DENSE_RANK() OVER(ORDER BY confirmed_cases DESC) AS country_rank
FROM confirmed
WHERE confirm_date = "2021-11-29" AND province_state = "New York"
);

SELECT * 
FROM top_counties;

/*6. the average number of confirmed cases in the TOP 10 is 200840.3000 and the 
conties have Kings, Queens, Suffolk, Nassau, Bronx, New York
Westchester, Erie, Monroe, Richmond*/
WITH top_ten AS
(
SELECT *
FROM top_counties
LIMIT 10
)

SELECT *,  AVG(confirmed_cases) OVER() AS top_ten_avg
FROM top_ten;

/*7. total number of cases in New York State as of
11/29/21 is 2722936*/
WITH current_confirmed AS
(
SELECT *
FROM top_counties
)
SELECT SUM(confirmed_cases) AS current_confirmed_cases
FROM current_confirmed;

/*8. */
CREATE TEMPORARY TABLE nyc_confirmed AS
(SELECT admin2 AS county_name, confirm_date, confirmed_cases, MONTH(confirm_date) AS confirm_month,
confirmed_cases - LAG(confirmed_cases,1) OVER(ORDER BY confirm_date) AS daily_increase
FROM confirmed
WHERE YEAR(confirm_date) = "2021" AND admin2 = "New York"
);

SELECT *
FROM nyc_confirmed;

/*9. FOR JAN. is 803.4333, FEB. is 625.3571, MAR. is 647.5484
 APR. is 386.4333, MAY. is 89.8710, JUN. is 33.3333, JULY is 139.8065, 
 AUG. is 360.0000, SEP. is 318.3000, OCT. is 189.6774,
 NOV is 236.8276, */
SELECT *, AVG(daily_increase) OVER(PARTITION BY confirm_month)AS avg_daily_increase
FROM nyc_confirmed;

/*10. 2021-03-24 and the cases that day is 5226 with 118986 total confirmed cases*/
WITH new_case_rank AS
(SELECT *,
RANK() OVER(ORDER BY daily_increase DESC) AS day_rank
FROM nyc_confirmed)

SELECT *
FROM new_case_rank
LIMIT 1;
