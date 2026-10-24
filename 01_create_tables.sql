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