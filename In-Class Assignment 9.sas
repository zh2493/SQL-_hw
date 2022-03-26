***********************************
*      IN-CLASS ASSIGNMENT 9      *
***********************************;

*Download the SAS dataset called Demographics to your computer and change the libname
 statement below to reflect the folder in which you've saved the file.;

libname sql "/home/u60931273/sasuser.v94";

*Run PROC CONTENTS to show the variables included in the Demographics data;
proc contents data=sql.demographics order=varnum;
run;

*1. Write a SQL query to display a list of the distinct continents represented in the data;
proc sql;
    SELECT DISTINCT CONT
    FROM sql.demographics;
quit;

*2. List the total population of each continent, ordered from highest to lowest;
proc sql;
    SELECT CONT, SUM(pop) AS total_pop
    FROM sql.demographics
    GROUP BY CONT
    ORDER BY total_pop DESC;
quit;  

*3. In the absence of a data dictionary, write a query that would help you determine
	which continent is represented by the number that had the highest population in #2.;
proc sql;
    SELECT CONT, NAME
    FROM sql.demographics
    WHERE CONT=95;
quit;

*4. Write a query to calculate the number of individuals who reside in urban areas in each country
	and save it into a new table called sql.urban. Name the variable you calculate as total_urban_pop.;
proc sql;
    CREATE TABLE sql.urban AS
    SELECT NAME, (pop*popUrban) AS total_urban_pop
    FROM sql.demographics;
quit;

*5. Write a query to display the maximum population value in the dataset.;
proc sql;
    SELECT MAX(pop) AS max_pop
    FROM sql.demographics;
quit;

*6. Use the query you wrote in question 5 as a subquery to find the country or countries
	linked to the highest population value.;
proc sql;
    SELECT NAME
    FROM sql.demographics
    WHERE pop=
    (SELECT MAX(pop) AS max_pop
    FROM sql.demographics);
quit;