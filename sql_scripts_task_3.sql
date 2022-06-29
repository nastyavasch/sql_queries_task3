
--Вывести количество фильмов в каждой категории, отсортировать по убыванию.



SELECT c."name" AS category_name, count(*) AS films_count
FROM film f 
INNER JOIN film_category fc ON f.film_id = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id 
GROUP BY c.category_id 
ORDER BY films_count DESC;


--Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.


SELECT concat(a.first_name,' ', a.last_name) AS actor_name, count(r.rental_id) AS rental_count
FROM film f
INNER JOIN inventory i  ON f.film_id = i.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id 
INNER JOIN film_actor fa ON fa.film_id = f.film_id 
INNER JOIN actor a ON a.actor_id  = fa.actor_id
GROUP BY a.actor_id
ORDER BY rental_count DESC
LIMIT 10;


--Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT sbfc.category, sbfc.total_sales
FROM sales_by_film_category sbfc 
ORDER BY sbfc.total_sales DESC 
LIMIT 1;


--без sales_by_film_category

SELECT c."name" AS category_name, sum(p.amount) AS money_amount
FROM film f 
INNER JOIN film_category fc ON f.film_id = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN inventory i ON i.film_id = f.film_id 
INNER JOIN rental r ON i.inventory_id = r.inventory_id 
INNER JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY category_name
ORDER BY money_amount DESC 
LIMIT 1;

--Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT f.title 
FROM film f
WHERE NOT EXISTS (SELECT i.film_id 
					FROM inventory i
					WHERE f.film_id = i.film_id)
ORDER BY f.title;

--Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”.
--Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

WITH actors_with_rank AS (SELECT actor_name, film_num, DENSE_RANK() OVER (ORDER BY film_num desc) AS act_rank
							FROM
								(SELECT concat(a.first_name,' ', a.last_name) AS actor_name,
										COUNT(*) AS film_num
								FROM actor a 
								INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
								INNER JOIN film f ON f.film_id = fa.film_id 
								INNER JOIN film_category fc ON fc.film_id = f.film_id 
								INNER JOIN category c ON c.category_id = fc.category_id 
								WHERE c."name" = 'Children'
								GROUP BY a.actor_id          
								ORDER BY film_num DESC) sub
							ORDER BY film_num DESC) 

SELECT actor_name, film_num
FROM actors_with_rank
WHERE act_rank <= 3;

--Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1).
--Отсортировать по количеству неактивных клиентов по убыванию.

SELECT c.city,
			SUM(CASE WHEN cust.active = 1 THEN 1 ELSE 0 END) AS active_count,
			SUM(CASE WHEN cust.active = 0 THEN 1 ELSE 0 END) AS inactive_count
FROM customer cust
INNER JOIN address a ON cust.address_id  = a.address_id
INNER JOIN city c ON c.city_id = a.city_id
GROUP BY c.city_id
ORDER BY inactive_count DESC;


--Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах
--(customer.address_id в этом city),и которые начинаются на букву “a”.
-- То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.

SELECT cat."name" AS category_name,
		c.city, 
		sum(date_part('hour',r.return_date - r.rental_date)) AS rent_hours 
FROM film f
INNER JOIN film_category fc ON fc.film_id = f.film_id 
INNER JOIN category cat ON cat.category_id = fc.category_id 
INNER JOIN inventory i ON i.film_id = f.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id 
INNER JOIN customer cust ON cust.customer_id = r.customer_id 
INNER JOIN address a ON a.address_id = cust.address_id 
INNER JOIN city c ON c.city_id = a.city_id 
WHERE r.return_date IS NOT NULL 
AND f.title LIKE ('A%')
AND c.city LIKE ('%-%')
GROUP BY cat.category_id, c.city_id  
ORDER BY rent_hours DESC;



