CREATE OR REPLACE PROCEDURE register_rent(
    p_inventory_id INTEGER, 
    p_customer_id INTEGER, 
    p_staff_id INTEGER
) AS $$
DECLARE 
    var_film_rent_time INTERVAL;  -- Declare the variable with a type
BEGIN


    INSERT INTO rental (
        rental_id, 
        rental_date, 
        inventory_id, 
        customer_id, 
        return_date, 
        staff_id, 
        last_update
    )
    VALUES (
        nextval('rental_rental_id_seq'),  -- Ensure the sequence name is correct
        NOW()::TIMESTAMP(0),  -- Directly using NOW() for rental_date
        p_inventory_id,
        p_customer_id,
        NULL,  -- Set return date based on rental duration
        p_staff_id,
        NOW()::TIMESTAMP(0)  -- Directly using NOW() for last_update
    );
END;
$$ LANGUAGE plpgsql;  -- Ensure you specify the language

CALL register_rent(1, 1, 1);

select * from rental
order by rental_id desc;

delete from rental where rental_id = 16053;

SELECT TO_TIMESTAMP('2024-10-01 14:30:53', 'YYYY-MM-DD HH24:MI:SS') AS converted_timestamp;