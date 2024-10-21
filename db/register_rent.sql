-- =========================================================
-- Procedure: register_rent
-- 
-- Descriptcion: 
-- This procedure is in charge of register a rent in the DVDRENTAL data base
-- 
-- Parameters:
--   p_inventory_id 	INTEGER	: Number of the inventory item the customer is renting
--  p_customer_id 		INTEGER	: ID of the customer who is renting the movie 
--  p_staff_id			INTEGER	: ID of the employee who is in charge of the rental
-- 
-- USE:
-- To call the customer procuder you can use the next script:
-- CALL register_rent(p_inventory_id, p_customer_id INTEGER, p_staff_id);
-- 
-- Example:
-- CALL register_rent(1, 1, 1);
-- =========================================================

CREATE OR REPLACE PROCEDURE register_rent(
    p_inventory_id INTEGER, 
    p_customer_id INTEGER, 
    p_staff_id INTEGER
)
SECURITY DEFINER -- this code allows to other users than the owner
				 -- to execute this function with the privileges of the owner	
AS $$
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

-- =========================================================
-- Testing scripts
-- =========================================================

-- TEST CALLS
CALL register_rent(1, 1, 1);
CALL register_rent(2, 2, 1);
CALL register_rent(3, 3, 2);
CALL register_rent(4, 4, 2);
CALL register_rent(5, 5, 3);
CALL register_rent(6, 6, 3);
CALL register_rent(7, 7, 4);
CALL register_rent(8, 8, 4);
CALL register_rent(9, 9, 5);
CALL register_rent(10, 10, 5);

-- DELETE TEST RECORDS
DELETE FROM rental WHERE inventory_id = 1 AND customer_id = 1;
DELETE FROM rental WHERE inventory_id = 2 AND customer_id = 2;
DELETE FROM rental WHERE inventory_id = 3 AND customer_id = 3;
DELETE FROM rental WHERE inventory_id = 4 AND customer_id = 4;
DELETE FROM rental WHERE inventory_id = 5 AND customer_id = 5;
DELETE FROM rental WHERE inventory_id = 6 AND customer_id = 6;
DELETE FROM rental WHERE inventory_id = 7 AND customer_id = 7;
DELETE FROM rental WHERE inventory_id = 8 AND customer_id = 8;
DELETE FROM rental WHERE inventory_id = 9 AND customer_id = 9;
DELETE FROM rental WHERE inventory_id = 10 AND customer_id = 10;



select * from rental
order by rental_id desc;

delete from rental where rental_id = 16053;

SELECT TO_TIMESTAMP('2024-10-01 14:30:53', 'YYYY-MM-DD HH24:MI:SS') AS converted_timestamp;