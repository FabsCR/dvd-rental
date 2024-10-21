-- =========================================================
-- Procedure: return_movie
-- 
-- Descriptcion: 
-- This procedure is in charge to return a rented movie
-- 
-- Parameters:
--   p_rental_id     INTEGER   : ID of movie is about to return
--
-- USE:
-- To call the customer procuder you can use the next script:
-- CALL return_movie(p_rental_id);
-- 
-- Example:
-- CALL return_movie(1);
-- =========================================================

CREATE OR REPLACE PROCEDURE return_movie(
    p_rental_id INTEGER
) 
SECURITY DEFINER -- this code allows to other users than the owner
				 -- to execute this function with the privileges of the owner	
AS $$
DECLARE 
    var_film_rent_time INTERVAL;  -- Declare the variable with a type
BEGIN


    UPDATE rental
SET return_date = NOW()::TIMESTAMP(0) 
	WHERE rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- Testing scripts
-- =========================================================

-- TEST CALLS
CALL return_movie(1);
CALL return_movie(2);
CALL return_movie(3);
CALL return_movie(4);
CALL return_movie(5);
CALL return_movie(6);
CALL return_movie(7);
CALL return_movie(8);
CALL return_movie(9);
CALL return_movie(10);