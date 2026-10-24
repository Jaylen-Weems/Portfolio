--Trigger Function
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

-- Trigger
CREATE TRIGGER trg_update_rental_summary
AFTER INSERT ON rental_detail_report
FOR EACH ROW
EXECUTE FUNCTION update_rental_summary();