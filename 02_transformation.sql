CREATE OR REPLACE FUNCTION get_rental_month(input_date TIMESTAMP)
RETURNS TEXT
LANGUAGE SQL
AS $$
    SELECT TO_CHAR(input_date, 'FMMonth YYYY');
$$;

-- Function test
SELECT rental_date, get_rental_month(rental_date) AS rental_month
FROM rental
LIMIT 10;