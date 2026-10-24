CREATE OR REPLACE PROCEDURE refresh_rental_report()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Clear both reporting tables
    TRUNCATE TABLE rental_detail_report, rental_summary_report;

    -- Load detailed rows; AFTER INSERT trigger maintains summary
    INSERT INTO rental_detail_report (
        rental_id,
        rental_date,
        rental_month,
        film_title,
        category_name,
        customer_id,
        payment_amount
    )
    SELECT
        r.rental_id,
        r.rental_date,
        get_rental_month(r.rental_date),
        f.title,
        c.name,
        r.customer_id,
        p.total_payment
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
END;
$$;
-- CALL refresh_rental_report();