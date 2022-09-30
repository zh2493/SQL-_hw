#CREATE THE SCHEMA
CREATE SCHEMA baby_names;

#APPLY SUBSEQUENT CODE TO THE SCHEMA
USE baby_names;

#CREATE 2019 TABLE
CREATE TABLE yob2019(
	yob SMALLINT(4),
    first_name VARCHAR(20),
    sex VARCHAR(1),
    frequency SMALLINT(5)
);

#CREATE 2020 TABLE
CREATE TABLE yob2020(
	yob SMALLINT(4),
    first_name VARCHAR(20),
    sex VARCHAR(1),
    frequency SMALLINT(5)
);

#CREATE COMBINED TABLE CALLED SSA_NAMES
CREATE TABLE ssa_names AS
SELECT * FROM yob2019
UNION
SELECT * FROM yob2020;

#QUESTION 1 - HOW MANY UNQUE NAMES WERE REPORTED IN 2019 AND 2020 COMBINED?
SELECT COUNT(DISTINCT first_name) AS unique_name
FROM ssa_names
# There are 34445 unique names were reported in 2019 and 2020 combined.


#QUESTION 2 - HOW MANY BABIES WERE INCLUDED IN THE DATA FOR EACH YEAR?
SELECT yob, SUM(frequency) AS num_babies
FROM ssa_names
GROUP BY yob;

# There are 3445321 babies included in the data for 2019. There are 3305259 babies included in the data for 2020.

#QUESTION 3 - LIST THE MOST POPULAR BOY AND GIRL NAMES OF EACH YEAR AND INCLUDE THEIR FREQUENCIES
SELECT yob, sex, first_name, MAX(frequency) AS max_freq
FROM ssa_names
GROUP BY yob, sex;
# In 2019, the most popular girl name is Olivia,18451. the most popular boy name is Liam,20502
# In 2020, the most popular girl name is Olivia, 17535. the most popular boy name is Liam, 19659, and 

#QUESTION 4 - LIST THE TOP 10 RANKED BOY NAMES FOR BOTH YEARS AND THEN GIVE THE TOTAL NUMBER OF BABIES THEY REPRESENT PER YEAR
SELECT *, SUM(frequency) OVER(PARTITION BY yob) AS total_number
FROM (
    SELECT *, RANK() OVER(PARTITION BY yob ORDER BY frequency DESC) AS name_rank
	FROM ssa_names
	WHERE sex = 'M' 
) AS boy_table
WHERE name_rank < 11;
#Here is top 10 ranked boy names for both years and give the total number of babies they represent per year
#The total number of babies they represent in 2019 is 141373, and 145435 in 2020.
/*
2019	Liam	M	20502	1	141373
2019	Noah	M	19048	2	141373
2019	Oliver	M	13891	3	141373
2019	William	M	13542	4	141373
2019	Elijah	M	13300	5	141373
2019	James	M	13087	6	141373
2019	Benjamin	M	12942	7	141373
2019	Lucas	M	12412	8	141373
2019	Mason	M	11408	9	141373
2019	Ethan	M	11241	10	141373
2020	Liam	M	19659	1	134156
2020	Noah	M	18252	2	134156
2020	Oliver	M	14147	3	134156
2020	Elijah	M	13034	4	134156
2020	William	M	12541	5	134156
2020	James	M	12250	6	134156
2020	Benjamin	M	12136	7	134156
2020	Lucas	M	11281	8	134156
2020	Henry	M	10705	9	134156
2020	Alexander	M	10151	10	134156
*/

#QUESTION 5 - WHAT IS THE MOST POPULAR BOY NAME FROM EITHER YEAR THAT BEGINS WITH R?  GIVE THE YEAR, NAME, AND FREQUENCY.

SELECT yob, first_name, frequency
FROM 
(
    SELECT *, RANK() OVER(PARTITION BY yob ORDER BY frequency DESC) AS name_rank
	FROM ssa_names
	WHERE first_name LIKE 'R%' AND sex = 'M' 
) AS derived
WHERE name_rank = 1;
# The most popular boy name from 2019 that begins with R is Ryan, 6087. 
# The most popular boy name from 2020 that begins with R is Ryan, 5286.


#QUESTION 6 - HOW MANY UNIQUE BOY NAMES THAT END IN 'I' OR 'O' WERE REPORTED IN 2019 and 2020 COMBINED, AND HOW MANY BABIES
#WERE GIVEN THOSE NAMES IN TOTAL?  REPORT BOTH NUMBERS IN ONE RESULT SET.
SELECT first_name, COUNT(first_name) OVER() AS num_unique, SUM(name_freq) OVER() AS total_babies
FROM (
    SELECT first_name, SUM(frequency) AS name_freq
    FROM ssa_names
    WHERE (sex = 'M')
    GROUP BY first_name
) AS boy
WHERE (RIGHT(first_name, 1) = 'I' OR RIGHT(first_name, 1) = 'O'); 
# There are 1968 unique boy names that end in 'I' OR 'O' were reported in 2019 and 2020 combined. 
# There are 314037 babies were given thoese names in total. 

#QUESTION 7 - COMBINE ALL NAME FREQUENCIES FROM 2019 AND 2020 AND THEN RANK EACH NAME BY SEX BASED ON COMBINED FREQUENCY.  
#THEN QUERY THOSE RESULTS TO FIND YOUR NAME AND ITS RANK.

WITH combine_table AS
(
	 SELECT first_name, sex, SUM(frequency) as combine_fre,  RANK() OVER(PARTITION BY sex ORDER BY SUM(frequency) DESC) AS name_rank
	 FROM ssa_names
	 GROUP BY first_name,sex
	 ORDER BY name_rank
)

SELECT * 
FROM combine_table
WHERE first_name = 'Hester';

#My name(Ziqian) did not appear in the list so I use my English name Hester and it is the 7 in girls rank.


#QUESTION 8 - LIST DISTINCT NAMES THAT WERE GIVEN TO BOTH GIRLS AND BOYS.  RESTRICT RESULTS TO NAMES THAT WERE GIVEN TO AT LEAST 
#1000 GIRLS AND 1000 BOYS.  ORDER THE RESULTING NAMES ALPHABETICALLY.

CREATE TEMPORARY TABLE m_table AS
(
      SELECT first_name, sex, SUM(frequency) as combined_fre
      FROM ssa_names
      WHERE sex = 'M'
	  GROUP BY first_name,sex
);

CREATE TEMPORARY TABLE f_table AS
(
      SELECT first_name, sex, SUM(frequency) as combined_fre
      FROM ssa_names
      WHERE sex = 'F'
	  GROUP BY first_name,sex
);

SELECT m.first_name, m.sex, m.combined_fre AS freq_boy, f.sex,f.combined_fre AS freq_girl
FROM m_table AS m
	INNER JOIN f_table AS f
    ON m.first_name = f.first_name
WHERE m.combined_fre >= 1000 AND f.combined_fre >= 1000
ORDER BY first_name
LIMIT 5;

# The 5 distinct names that were given to both boys and girls, and were given to at least
# 1000 girls and 1000 boys, with ordered alphabetically, are Alexis, Amari, Angel, Ari, and Armani.




