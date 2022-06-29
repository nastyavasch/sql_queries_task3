--Âûâåñòè êîëè÷åñòâî ôèëüìîâ â êàæäîé êàòåãîðèè, îòñîðòèðîâàòü ïî óáûâàíèþ.

SELECT c."name" AS category_name, count(*) AS films_count
FROM film f 
INNER JOIN film_category fc ON f.film_id = fc.film_id 
INNER JOIN category c ON fc.category_id = c.category_id 
GROUP BY c.category_id 
ORDER BY films_count DESC;

--Âûâåñòè 10 àêòåðîâ, ÷üè ôèëüìû áîëüøåãî âñåãî àðåíäîâàëè, îòñîðòèðîâàòü ïî óáûâàíèþ.

SELECT concat(a.first_name,' ', a.last_name) AS actor_name, count(r.rental_id) AS rental_count
FROM film f
INNER JOIN inventory i  ON f.film_id = i.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id 
INNER JOIN film_actor fa ON fa.film_id = f.film_id 
INNER JOIN actor a ON a.actor_id  = fa.actor_id
GROUP BY a.actor_id
ORDER BY rental_count DESC
LIMIT 10;

--Âûâåñòè êàòåãîðèþ ôèëüìîâ, íà êîòîðóþ ïîòðàòèëè áîëüøå âñåãî äåíåã.


SELECT sbfc.category, sbfc.total_sales
FROM sales_by_film_category sbfc 
ORDER BY sbfc.total_sales DESC 
LIMIT 1;

--áåç sales_by_film_category

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

--Âûâåñòè íàçâàíèÿ ôèëüìîâ, êîòîðûõ íåò â inventory. Íàïèñàòü çàïðîñ áåç èñïîëüçîâàíèÿ îïåðàòîðà IN.

SELECT f.title 
FROM film f
WHERE NOT EXISTS (SELECT i.film_id 
					FROM inventory i
					WHERE f.film_id = i.film_id)
ORDER BY f.title;

--Âûâåñòè òîï 3 àêòåðîâ, êîòîðûå áîëüøå âñåãî ïîÿâëÿëèñü â ôèëüìàõ â êàòåãîðèè “Children”.
--Åñëè ó íåñêîëüêèõ àêòåðîâ îäèíàêîâîå êîë-âî ôèëüìîâ, âûâåñòè âñåõ.

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

--Âûâåñòè ãîðîäà ñ êîëè÷åñòâîì àêòèâíûõ è íåàêòèâíûõ êëèåíòîâ (àêòèâíûé — customer.active = 1).
--Îòñîðòèðîâàòü ïî êîëè÷åñòâó íåàêòèâíûõ êëèåíòîâ ïî óáûâàíèþ.

SELECT c.city,
			SUM(CASE WHEN cust.active = 1 THEN 1 ELSE 0 END) AS active_count,
			SUM(CASE WHEN cust.active = 0 THEN 1 ELSE 0 END) AS inactive_count
FROM customer cust
INNER JOIN address a ON cust.address_id  = a.address_id
INNER JOIN city c ON c.city_id = a.city_id
GROUP BY c.city_id
ORDER BY inactive_count DESC;

--Âûâåñòè êàòåãîðèþ ôèëüìîâ, ó êîòîðîé ñàìîå áîëüøîå êîë-âî ÷àñîâ ñóììàðíîé àðåíäû â ãîðîäàõ
--(customer.address_id â ýòîì city),è êîòîðûå íà÷èíàþòñÿ íà áóêâó “a”.
-- Òî æå ñàìîå ñäåëàòü äëÿ ãîðîäîâ â êîòîðûõ åñòü ñèìâîë “-”. Íàïèñàòü âñå â îäíîì çàïðîñå.

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



