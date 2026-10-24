SELECT * FROM rental_detail_report LIMIT 10;

SELECT * FROM rental_summary_report ORDER BY total_revenue DESC;

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT rental_id) AS unique_rentals
FROM rental_detail_report;

SELECT
    (SELECT SUM(payment_amount) FROM rental_detail_report) AS detailed_revenue,
    (SELECT SUM(total_revenue) FROM rental_summary_report) AS summary_revenue;