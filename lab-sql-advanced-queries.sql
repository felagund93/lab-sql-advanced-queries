# Lab | SQL Advanced queries

-- In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals.

### Instructions

-- 1. List each pair of actors that have worked together.
WITH cte1 AS (
	SELECT a.actor_id, a.first_name, a.last_name, c.film_id, c.title FROM sakila.actor a
	LEFT JOIN sakila.film_actor b ON a.actor_id=b.actor_id
	JOIN sakila.film c ON b.film_id = c.film_id
	) -- cte for the actor/film_actor/film join
SELECT a1.first_name, a1.last_name, a2.first_name, a2.last_name, a1.title FROM cte1 a1
JOIN cte1 a2
ON a1.actor_id <> a2.actor_id
AND a1.film_id = a2.film_id
WHERE a1.actor_id > a2.actor_id
ORDER BY a1.film_id;

-- 2. For each film, list actor that has acted in more films.
WITH cte1 AS (SELECT actor_id, COUNT(film_id) AS movies_in FROM sakila.film_actor
GROUP BY actor_id), /* First, I created a cte (cte1) to count how many movies each actor has starred in, naming the column "movies_in"*/
cte2 AS (
SELECT a1.film_id, a1.actor_id, a2.movies_in,
DENSE_RANK() OVER (PARTITION BY a1.film_id ORDER BY a2.movies_in DESC) AS rank_actor
FROM sakila.film_actor a1
LEFT JOIN cte1 a2 ON a1.actor_id=a2.actor_id) /*Next, I created a second cte (cte2). 
Here, I joined the cte1 with the film_actor table and ranked the actors by number of films they star in, i.e., by "movies_in"*/
SELECT film.title, actor.first_name, actor.last_name, cte2.movies_in AS starred_in_movies
FROM sakila.film 
JOIN cte2 ON film.film_id=cte2.film_id
JOIN sakila.actor ON cte2.actor_id=actor.actor_id
WHERE rank_actor=1; /*Lastly, I joined the tables "film" and "actor" to the cte2, to display the title of the movie, and the name and lastname of the actor who acted in 
more films that stars in that movie. To select only the first actor, I filtered with the WHERE clause.*/