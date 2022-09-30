USE sakila;

/* Question 1 total time of retrieving indexed last name is 0.147 ms, 
the total time of retrieving the first name is 0.159 ms so indexed last name is faster.
*/

EXPLAIN ANALYZE
SELECT last_name
FROM customer;
# Covering index scan on customer using idx_last_name  (cost=61.15 rows=599) (actual time=0.032..0.147 rows=599 loops=1)
 
EXPLAIN ANALYZE
SELECT first_name
FROM customer;
# Table scan on customer  (cost=61.15 rows=599) (actual time=0.035..0.159 rows=599 loops=1)
 
/* Question 2 total time of sorting by indexed last name is 0.414ms, 
the total time of sorting by first name is 1.041ms so indexed last name is faster.
*/ 
EXPLAIN ANALYZE
SELECT last_name
FROM customer
ORDER BY last_name DESC;
#  Covering index scan on customer using idx_last_name (reverse)  (cost=61.15 rows=599) (actual time=0.067..0.414 rows=599 loops=1)\n'

EXPLAIN ANALYZE
SELECT first_name
FROM customer
ORDER BY first_name DESC;
#   Sort: customer.first_name DESC  (cost=61.15 rows=599) (actual time=0.710..0.745 rows=599 loops=1)\n    
# -> Table scan on customer  (cost=61.15 rows=599) (actual time=0.055..0.296 rows=599 loops=1)\n'

/* Question 3 total time of inner join is 0.354ms, 
the total time of left join is 0.358  ms 
so inner join is faster.
*/ 
EXPLAIN ANALYZE
SELECT c.category_id, c.name
FROM category AS c
    INNER JOIN film_category AS f
    USING (category_id);
# '-> Nested loop inner join  (cost=105.97 rows=1000) (actual time=0.036..0.318 rows=1000 loops=1)
#    -> Table scan on c  (cost=1.85 rows=16) (actual time=0.020..0.022 rows=16 loops=1)
#    -> Covering index lookup on f using fk_film_category_category (category_id=c.category_id)  (cost=0.65 rows=62) (actual time=0.007..0.014 rows=62 loops=16)

EXPLAIN ANALYZE    
SELECT c.category_id, c.name
FROM category AS c
    LEFT JOIN film_category AS f
    USING (category_id);
# '-> Nested loop left join  (cost=105.97 rows=1000) (actual time=0.035..0.322 rows=1000 loops=1)
#    -> Table scan on c  (cost=1.85 rows=16) (actual time=0.019..0.022 rows=16 loops=1)
#    -> Covering index lookup on f using fk_film_category_category (category_id=c.category_id)  (cost=0.65 rows=62) (actual time=0.007..0.014 rows=62 loops=16)

/* Question 4 there are 2 records
total time of get records end with specific words end in is 0.642ms, 
much longer than retrieve 599 unindexed first names.
the speed of leading wildcard characters in search strings need much more than though just few records.
*/ 
EXPLAIN ANALYZE    
SELECT title
FROM film
where title like  '%DINOSAUR';
#-> Filter: (film.title like '%DINOSAUR')  (cost=103.00 rows=111) (actual time=0.040..0.403 rows=2 loops=1)
#     -> Covering index scan on film using idx_title  (cost=103.00 rows=1000) (actual time=0.037..0.239 rows=1000 loops=1)
 
/* Question 5 
take 4.583 ms to select all fields in the rental table,
take 11.726 ms to select all fields in the rental table and adding an unnecessary clause,
the second one take much more time.
*/ 
EXPLAIN ANALYZE
SELECT *
FROM rental;
#'-> Table scan on rental  (cost=1625.05 rows=16008) (actual time=0.035..4.583 rows=16044 loops=1)\n'

EXPLAIN ANALYZE
SELECT *
FROM rental
WHERE rental_id > 0;
#-> Filter: (rental.rental_id > 0)  (cost=1606.48 rows=8004) (actual time=0.013..6.443 rows=16044 loops=1)
#     -> Index range scan on rental using PRIMARY over (0 < rental_id)  (cost=1606.48 rows=8004) (actual time=0.012..5.283 rows=16044 loops=1)
 
/* Question 6
take 4.961 ms to get the id of actor in in both two table with select distinct and inner join,
take 1.886 ms to get the id of actor in in both two table with sub query,
the second one is much faster.
*/ 
EXPLAIN ANALYZE    
SELECT a.actor_id
FROM actor AS a
INNER JOIN film_actor AS f
USING (actor_id)
GROUP BY a.actor_id;
#-> Group (no aggregates)  (cost=1163.93 rows=5462) (actual time=0.060..2.593 rows=200 loops=1)\n    
#-> Nested loop inner join  (cost=617.73 rows=5462) (actual time=0.044..2.283 rows=5462 loops=1)\n        
#-> Covering index scan on a using PRIMARY  (cost=20.25 rows=200) (actual time=0.029..0.076 rows=200 loops=1)\n        
#-> Covering index lookup on f using PRIMARY (actor_id=a.actor_id)  (cost=0.27 rows=27) (actual time=0.005..0.009 rows=27 loops=200)\n'


# Group aggregate: count(film_actor.actor_id)  (cost=1101.95 rows=5462) (actual time=0.035..1.366 rows=997 loops=1)
#     -> Covering index scan on film_actor using idx_fk_film_id  (cost=555.75 rows=5462) (actual time=0.030..1.072 rows=5462 loops=1)
EXPLAIN ANALYZE 
SELECT a.actor_id
FROM actor AS a
WHERE actor_id IN
	(SELECT f.actor_id
	 FROM film_actor AS f
	)
GROUP BY a.actor_id;
#'-> Group (no aggregates)  (cost=1163.93 rows=5462) (actual time=0.045..0.922 rows=200 loops=1)
#    -> Nested loop semijoin  (cost=617.73 rows=5462) (actual time=0.038..0.894 rows=200 loops=1)
#        -> Covering index scan on a using PRIMARY  (cost=20.25 rows=200) (actual time=0.026..0.066 rows=200 loops=1)
#        -> Covering index lookup on f using PRIMARY (actor_id=a.actor_id)  (cost=7.38 rows=27) (actual time=0.004..0.004 rows=1 loops=200)
