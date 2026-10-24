SELECT
    r.rental_id,
    r.rental_date,
    r.customer_id,
    p.total_payment AS payment_amount,
    f.title AS film_title,
    c.name AS category_name,
    get_rental_month(r.rental_date) AS rental_month
FROM rental AS r
INNER JOIN (
    SELECT rental_id, SUM(amount) AS total_payment
    FROM payment
    WHERE rental_id IS NOT NULL
    GROUP BY rental_id
) AS p
    ON r.rental_id = p.rental_id
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id;