# Lab | SQL Advanced queries
USE sakila;
# 1. List each pair of actors that have worked together.
SELECT A1.actor_id, A2.actor_id, film.title
FROM sakila.film_actor as A1 , sakila.film_actor as A2
JOIN film
ON film.film_id = A2.film_id
WHERE A1.actor_id <> A2.actor_id;

# 2. For each film, list actor that has acted in more films (more apps).

SELECT title, actor_id 
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id 
WHERE fa.actor_id IN (
SELECT actor_id 
FROM film_actor
GROUP BY actor_id
)
ORDER BY actor_id ASC;

CREATE TEMPORARY TABLE app 
SELECT title, actor_id 
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id 
WHERE fa.actor_id IN (
SELECT actor_id 
FROM film_actor
GROUP BY actor_id
)
ORDER BY actor_id ASC;

# aplicar dense rank
SELECT * FROM app;

SELECT title, actor_id, ROW_NUMBER() OVER (PARTITION BY actor_id ORDER BY actor_id ASC) AS "most_app"
FROM app;

CREATE TEMPORARY TABLE most_app 
SELECT title, actor_id, RANK() OVER (ORDER BY actor_id ASC) AS "most_app"
FROM app;

SELECT *
FROM most_app;

CREATE TEMPORARY TABLE final_count
SELECT title, actor_id, ROW_NUMBER() OVER (PARTITION BY actor_id ORDER BY actor_id ASC) AS "most_app"
FROM app;


SELECT *
FROM final_count;

SELECT actor_id, MAX(most_app) as max_apps
FROM final_count
GROUP BY actor_id
ORDER BY max_apps DESC;

CREATE TEMPORARY TABLE final_count2
SELECT actor_id, MAX(most_app) as max_apps
FROM final_count
GROUP BY actor_id
ORDER BY max_apps DESC;

SELECT f.title, fa.actor_id, fc.max_apps
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN final_count2 fc
ON fa.actor_id = fc.actor_id
WHERE fa.actor_id IN (SELECT MAX(most_app) as max_apps FROM final_count GROUP BY actor_id);

