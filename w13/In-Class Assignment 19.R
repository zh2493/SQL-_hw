##################################
# READING CSV FILES FROM THE WEB #
##################################

#Add the URL inside the quotes
url <- "https://healthdata.gov/api/views/j8mb-icvb/rows.csv?accessType=DOWNLOAD"

#Assign the csv data to a data frame
covid_pcr <- read.csv(url)

#Show the column names in the data frame
names(covid_pcr)

#Show the first few rows of the data frame
head(covid_pcr)

####################### SQL #######################

install.packages("sqldf")
library(sqldf)

#QUESTION 1 - How many distinct states and FEMA regions are reported in the dataset? 
sqldf("SELECT COUNT(DISTINCT state) AS state_num, COUNT(DISTINCT fema_region) AS fema_num
       FROM covid_pcr")

#56 distinct states and 10 distinct FEMA regions are reported in the dataset

#QUESTION 2 - Write a query to display the earliest reporting date for each state.  Is it the 
#same for each state?
sqldf("SELECT state_name, MIN(date) AS earliest_date
      FROM covid_pcr
      GROUP BY state_name")

#the earliest reporting date for each state is different

#QUESTION 3 - Using your query from Question 2 as a subquery, find the state or territory that 
#started reporting the latest. Give the state name and the date that state/territory started reporting.
#No need to account for ties.

sqldf("SELECT state_name, MAX(date) AS latest_date 
       FROM covid_pcr
       WHERE (state_name, date) IN
             (SELECT state_name, MIN(date) AS earliest_date 
             FROM covid_pcr
             GROUP BY state_name)")
#Marshall Islands reporting the latest, 2020/05/07

#QUESTION 4 - What is the total number of positive, inconclusive, and negative PCR test results
#across all states/territories as of 12/10/21?

sqldf("SELECT SUM(total_results_reported) AS total_pos, overall_outcome
      FROM covid_pcr
      WHERE date = '2021/12/10'
      GROUP BY overall_outcome")
#as of 12/10/21, the total number of positive is 51886685, the total number of inconclusive is 1426037, and the total number of negative is 635008710.   

#QUESTION 5 - Which state/territory had the highest number of new positive results reported in a single day?  Be sure
#to account for ties if multiple states/territories or multiple days share the highest number.  Give the name of the state/territory
#and the date and number of new positive results reported on that highest day.  (HINT: utilize a subquery)

sqldf("SELECT state_name, date, new_results_reported
      FROM covid_pcr
        WHERE(overall_outcome = 'Positive')
        GROUP BY state_name, date
        HAVING new_results_reported = 
      (SELECT new_results_reported 
        FROM covid_pcr
        WHERE(overall_outcome = 'Positive')
        GROUP BY state_name, date
        ORDER BY new_results_reported DESC
        LIMIT 1)")

# California has the highest number of new positive results reported in a single day, 125420 cases on 2022/01/06.


###################################################################
# PULLING JSON DATA FROM THE WEB USING HTTR AND JSONLITE PACKAGES #
###################################################################

install.packages("httr")
library(httr)

install.packages("jsonlite")  #This package will help convert JSON data to a data frame
library(jsonlite)


#Restrict this data only to ZIP code 10032 and use SQL to provide an insight about restaurant 
#violations in the campus neighborhood.

#Pull restaurant violations data for Washington Heights
wahi <- GET("https://data.cityofnewyork.us/resource/43nn-pn8j.json", query = list("zipcode" = 10032))
new <- content(wahi, "text")

#Create data frame from JSON data
wahi_df <- fromJSON(new) #NOTE: this will be limited to 1000 records due to throttling

#Show variable names for new data frame
colnames(wahi_df)


####################### SQL #######################

#QUESTION 6 - How many critical violations are reported in this sample of inspections?

sqldf("SELECT COUNT(critical_flag) AS num_cri_vio
      FROM wahi_df
      WHERE critical_flag = 'Critical'")
#511 critical violations are reported in this sample of inspections

#QUESTION 7 - Give the name and address (building, street) of restaurant(s) with the highest 
#number of critical violations.  Account for possible ties in your results.

sqldf("SELECT dba, building, street, COUNT(critical_flag) AS count_critical
       FROM wahi_df
         WHERE critical_flag = 'Critical' 
         GROUP BY dba, building, street
         HAVING count_critical =
         (SELECT COUNT(critical_flag) AS count_critical
         FROM wahi_df
         WHERE critical_flag = 'Critical' 
         GROUP BY dba, building, street
         ORDER BY COUNT(critical_flag) DESC
         LIMIT 1)")

# JOHN'S FRIED CHICKEN in building 3853, BROADWAY has the highest number of critical violations with 28

#QUESTION 8 - Similarly to question 8, give the name and address (building, street) of 
#restaurant(s) with the most A grades.  Account for possible ties in your results.
sqldf("SELECT dba, building, street, COUNT(grade) AS num_A_grade
       FROM wahi_df
         GROUP BY dba, building, street
         HAVING num_A_grade =
      (SELECT COUNT(grade) AS num_A_grade
         FROM wahi_df
         WHERE grade = 'A' 
         GROUP BY dba, building, street
         ORDER BY COUNT(grade) DESC
         LIMIT 1)")
#The restaurant with the most A grades is AU BON PAIN, COLUMBIA UNIVERSITY MEDICAL CENTER BOOKSTORE CAFE, EL PITALLITO RESTAURANT, LA FIESTA RESTAURANT     3789              BROADWAY          10
#LAS PALMAS RESTAURANT and SBARRO. The address is above, with 10 A grades.

#QUESTION 9 - Create a data frame called closed containing restaurants that were indicated 
#to be closed in the action field.  The data frame should contain the restaurant name, 
#address (building, street), inspection date, and action.

closed <- sqldf("SELECT dba, building, street, inspection_date, action
                 FROM wahi_df
                 WHERE action LIKE 'Establishment closed%' ")
#there are 38 restaurants were indicated to be closed in the action field

#QUESTION 10 - List the restaurants included in the closed data frame and order them by number 
#of closures, from most to least.  Include the restaurant name and address.

sqldf("SELECT dba, building, street, COUNT(action) AS num_closures
       FROM closed
       GROUP BY dba, building, street
       ORDER BY num_closures DESC")
#above is the list

#QUESTION 11 - Use SQL to answer a question of your choice about restaurant violations in the 
#campus neighborhood.

# Create a data frame called hot_food containing restaurants that violation_description were indicated with	Hot food.
#The data frame should contain the restaurant name, 
#address (building, street), inspection date, and violation_description.
hot_food <- sqldf("SELECT dba, building, street, inspection_date, violation_description
                 FROM wahi_df
                 WHERE violation_description LIKE 'Hot food%' ")
