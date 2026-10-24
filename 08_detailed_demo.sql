-- ============================================================
-- PART B: USER-DEFINED TRANSFORMATION FUNCTION
-- ============================================================
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

-- ============================================================
-- PART C: REPORTING TABLES
-- ============================================================
CREATE TABLE rental_detail_report (
    rental_id INTEGER,
    rental_date TIMESTAMP,
    rental_month VARCHAR(255),
    film_title VARCHAR(255),
    category_name VARCHAR(255),
    customer_id INTEGER,
    payment_amount NUMERIC(10,2)
);

CREATE TABLE rental_summary_report (
    category_name VARCHAR(255),
    total_rentals INTEGER,
    total_revenue NUMERIC(10,2)
);

-- Verify tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('rental_detail_report', 'rental_summary_report');

-- ============================================================
-- PART D: RAW DATA EXTRACTION
-- ============================================================
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

-- Investigate rentals with multiple payment records
SELECT rental_id, COUNT(*) AS payment_count
FROM payment
WHERE rental_id IS NOT NULL
GROUP BY rental_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC;

-- Validate row grain of extraction: expected 14592 total and 14592 unique
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT rental_id) AS unique_rentals
FROM (
    SELECT r.rental_id
    FROM rental AS r
    INNER JOIN (
        SELECT rental_id, SUM(amount) AS total_payment
        FROM payment
        WHERE rental_id IS NOT NULL
        GROUP BY rental_id
    ) AS p ON r.rental_id = p.rental_id
    INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
    INNER JOIN film AS f ON i.film_id = f.film_id
    INNER JOIN film_category AS fc ON f.film_id = fc.film_id
    INNER JOIN category AS c ON fc.category_id = c.category_id
) AS rental_data;

-- ============================================================
-- PART E: TRIGGER FUNCTION AND TRIGGER
-- ============================================================
-- Add uniqueness to category in summary table (first-time setup only)
ALTER TABLE rental_summary_report
ADD CONSTRAINT unique_category_name UNIQUE (category_name);

CREATE OR REPLACE FUNCTION update_rental_summary()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO rental_summary_report (
        category_name,
        total_rentals,
        total_revenue
    )
    VALUES (
        NEW.category_name,
        1,
        NEW.payment_amount
    )
    ON CONFLICT (category_name)
    DO UPDATE SET
        total_rentals = rental_summary_report.total_rentals + 1,
        total_revenue = rental_summary_report.total_revenue
                        + EXCLUDED.total_revenue;

    RETURN NEW;
END;
$$;

-- First-time setup only; do not recreate if trigger already exists
CREATE TRIGGER trg_update_rental_summary
AFTER INSERT ON rental_detail_report
FOR EACH ROW
EXECUTE FUNCTION update_rental_summary();

-- ============================================================
-- PART F: STORED PROCEDURE
-- ============================================================
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

-- Run refresh only when intentionally updating the report
-- CALL refresh_rental_report();

-- ============================================================
-- REPORTING AND VALIDATION (SAFE READ-ONLY QUERIES)
-- ============================================================
SELECT * FROM rental_detail_report LIMIT 10;

SELECT * FROM rental_summary_report ORDER BY total_revenue DESC;

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT rental_id) AS unique_rentals
FROM rental_detail_report;

SELECT
    (SELECT SUM(payment_amount) FROM rental_detail_report) AS detailed_revenue,
    (SELECT SUM(total_revenue) FROM rental_summary_report) AS summary_revenue;
