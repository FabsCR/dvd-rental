CREATE OR REPLACE PROCEDURE return_movie(
    p_rental_id INTEGER
) AS $$
DECLARE 
    var_film_rent_time INTERVAL;  -- Declare the variable with a type
BEGIN


    UPDATE rental
SET return_date = NOW()::TIMESTAMP(0) 
	WHERE rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;  -- Ensure you specify the language

CALL return_movie(16054);