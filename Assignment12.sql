USE sakila;

#Question 1 – there are 200 actors in the database
SELECT COUNT(actor_id) AS number
FROM actor;

#Question 2 – actor id of 81, SCARLETT.DAMON and 124 SCARLETT.BENING have the first name Scarlett
SELECT *
FROM actor
WHERE first_name = "Scarlett";

#Question 3 –  actor last names with KILMER appear 5 times, NOLTE and TEMPLE appear 4 times
SELECT last_name, COUNT(last_name) AS time
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=4;

#Question 4 – 
/*REESE.KILMER
MENA.TEMPLE
FAY.KILMER
WARREN.NOLTE
SALMA.NOLTE
ALBERT.NOLTE
#RUSSELL.TEMPLE
#JAYNE.NOLTE
MINNIE.KILMER
OPRAH.KILMER
BURT.TEMPLE
THORA.TEMPLE
last names appear 4 or more times*/

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name IN
    (SELECT last_name
    FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name) >=4);
    
#Question 5 – there are 376 different districts do the customers come from
SELECT COUNT(DISTINCT district) AS num_dis
FROM address
  INNER JOIN customer
  ON address.address_id = customer.address_id;
  
#Question 6 – there are 108 different countries do the customers come from.
SELECT COUNT(DISTINCT country) AS num_coun
FROM country
WHERE country_id IN
(SELECT country_id
FROM city
WHERE city_id IN
    (SELECT address.city_id
    FROM address
    INNER JOIN customer
    ON address.address_id = customer.address_id));

#Question 7 - GINA.DEGENERES appeared in the most films, 42 films.
SELECT film_actor.actor_id, actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS act_num
FROM film_actor
INNER JOIN actor
ON film_actor.actor_id = actor.actor_id
GROUP BY actor_id
ORDER BY act_num DESC
LIMIT 1;

#Question 8 - NATALIE.HOPKINS did the most action films.
SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS act_num
FROM actor
    INNER JOIN film_actor
    ON actor.actor_id = film_actor.actor_id
    INNER JOIN film_category
    ON film_actor.film_id = film_category.film_id
    INNER JOIN category
    ON film_category.category_id = category.category_id
WHERE category.name = "Action"
GROUP BY actor_id, actor.first_name, actor.last_name
ORDER BY act_num DESC
LIMIT 1;

#Question 9 - Music has the smallest number of records recorded in the database
SELECT category.name, COUNT(film_category.film_id) AS num_record
FROM category
    INNER JOIN film_category
    ON category.category_id = film_category.category_id 
GROUP BY category.name
ORDER BY num_record
LIMIT 1;

#Question 10 - 115.2720 minutes  is the average running time of all movies in the database
SELECT AVG(length) AS average_time
FROM film;

#Question 11 - the average running time of each category of movie
/*'Action', '111.6094'
'Animation', '111.0152'
'Children', '109.8000'
'Classics', '111.6667'
'Comedy', '115.8276'
'Documentary', '108.7500'
'Drama', '120.8387'
'Family', '114.7826'
'Foreign', '121.6986'
'Games', '127.8361'
'Horror', '112.4821'
'Music', '113.6471'
'New', '111.1270'
'Sci-Fi', '108.1967'
'Sports', '128.2027'
'Travel', '113.3158'*/

SELECT category.name, AVG(length) AS average_time
FROM film
INNER JOIN film_category
    ON film.film_id = film_category.film_id
    INNER JOIN category
    ON film_category.category_id = category.category_id
GROUP BY category.name;

#Question 12 - The longest movie in the database are
/*CHICAGO NORTH
CONTROL ANTHEM
DARN FORRESTER
GANGS PRIDE
HOME PITY
MUSCLE BRIGHT
POND SEATTLE
SOLDIERS EVOLUTION
SWEET BROTHERHOOD
WORST BANGER
and is 185 minutes*/
 
SELECT title, length
FROM film
WHERE length = 
(SELECT MAX(length) AS max_time
FROM film
LIMIT 1);

#Question 13 - 5.0252 is the average length of time between movie rental and movie return
SELECT AVG(DATEDIFF(return_date,rental_date)) AS avg_time
FROM rental;

#Question 14 - These 3 customers take the longest to return their movie rentals
/*315	KENNETH	GOODEN	6.4375
187	BRITTANY	RILEY	6.3929
321	KEVIN	SCHULER	6.3636*/
SELECT customer.customer_id, customer.first_name, customer.last_name, AVG(DATEDIFF(return_date,rental_date)) AS avg_delay
FROM rental
    INNER JOIN customer
    ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY avg_delay DESC
LIMIT 3;

#Question 15 - Jon had their customers spend a higher amount per rental, and is 4.245125
SELECT staff.first_name, staff.staff_id, AVG(payment.amount) AS avg_pay
FROM staff
    INNER JOIN payment
    ON staff.staff_id = payment.staff_id
GROUP BY staff.first_name, staff.staff_id
ORDER BY avg_pay DESC
LIMIT 1;

#Question 16 Which staff member had their customers take longer to return their movie rentals, on average. Mike or Jon? Give the amount

#John, with average of 5.
SELECT staff.first_name, staff.staff_id, AVG(DATEDIFF(return_date,rental_date)) AS avg_time
FROM staff
    INNER JOIN rental
    ON staff.staff_id = rental.staff_id
GROUP BY staff.first_name, staff.staff_id
ORDER BY avg_time DESC
LIMIT 1;
