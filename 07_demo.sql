-- 1. View detailed rental transactions
SELECT *
FROM rental_detail_report
LIMIT 10;


-- 2. View category-level revenue performance
SELECT *
FROM rental_summary_report
ORDER BY total_revenue DESC;


-- 3. Demonstrate the transformation function
SELECT
    rental_date,
    get_rental_month(rental_date) AS rental_month
FROM rental
LIMIT 10;


-- 4. Execute the stored procedure
CALL refresh_rental_report();


-- 5. Validate the detailed report
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT rental_id) AS unique_rentals
FROM rental_detail_report;


-- 6. Validate summary revenue
SELECT
    (SELECT SUM(payment_amount)
     FROM rental_detail_report) AS detailed_revenue,

    (SELECT SUM(total_revenue)
     FROM rental_summary_report) AS summary_revenue;


-- 7. Display the final business report
SELECT
    category_name,
    total_rentals,
    total_revenue
FROM rental_summary_report
ORDER BY total_revenue DESC;