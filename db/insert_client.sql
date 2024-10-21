-- =========================================================
-- Procedure: insert_customer
-- 
-- Descriptcion: 
-- This procedure is in charge to insert a new register in the table
-- 'customer'. it uses a sequence to create the unique id
-- 
-- Parameters:
--   p_store_id      INTEGER   : ID of the store that the customer is registered
--   p_first_name    VARCHAR   : Customer name.
--   p_last_name     VARCHAR   : Customer last name.
--   p_email         VARCHAR   : Customer email.
--   p_address_id    INTEGER   : Customer Address ID.
--   p_active_bool   BOOLEAN   : Active State.
-- 
-- USE:
-- To call the customer procuder you can use the next script:
-- CALL insert_customer(p_store_id, p_first_name, p_last_name, p_email, p_address_id, p_active_bool);
-- 
-- Example:
-- CALL insert_customer(1, 'Juan', 'Pérez', 'juan.perez@testuserbd2.com', 101, TRUE);
-- =========================================================

CREATE OR REPLACE PROCEDURE insert_customer(	
	IN p_store_id INTEGER,        -- store ID
	IN p_first_name VARCHAR,      -- customer's first name
	IN p_last_name VARCHAR,       -- customer's last name
	IN p_email VARCHAR,           -- customer's email
	IN p_address_id INTEGER,      -- address ID
	IN p_active_bool BOOLEAN      -- status of the customer
)
LANGUAGE plpgsql
SECURITY DEFINER -- this code allows to other users than the owner
				 -- to execute this function with the privileges of the owner			
AS $$
BEGIN
	-- insert a new record into the 'customer' table
	INSERT INTO customer(
		customer_id,               -- unique customer ID
		store_id, 
		first_name, 
		last_name, 
		email, 
		address_id, 
		activebool,               -- indicates if the customer is active
		create_date,              -- creation date of the record
		last_update,              -- last update timestamp
		active                    -- customer status
	)
	VALUES (
		nextval('customer_customer_id_seq'),  -- gets the next value from the sequence
		p_store_id,
		p_first_name,
		p_last_name,
		p_email,
		p_address_id,
		true,                                -- set as active by default
		CURRENT_DATE,                        -- set the creation date to the current date
		CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
		1                                    -- active status
	);
END;
$$;



--TEST CALLS
CALL insert_customer(1, 'Juan', 'Pérez', 'juan.perez@testuserbd2.com', 101, TRUE);
CALL insert_customer(2, 'Ana', 'Gómez', 'ana.gomez@testuserbd2.com', 102, TRUE);
CALL insert_customer(3, 'Luis', 'Martínez', 'luis.martinez@testuserbd2.com', 103, TRUE);
CALL insert_customer(4, 'María', 'López', 'maria.lopez@testuserbd2.com', 104, TRUE);
CALL insert_customer(5, 'Carlos', 'Hernández', 'carlos.hernandez@testuserbd2.com', 105, TRUE);
CALL insert_customer(6, 'Laura', 'Torres', 'laura.torres@testuserbd2.com', 106, TRUE);
CALL insert_customer(7, 'Javier', 'Ramírez', 'javier.ramirez@testuserbd2.com', 107, TRUE);
CALL insert_customer(8, 'Sofía', 'Cruz', 'sofia.cruz@testuserbd2.com', 108, TRUE);
CALL insert_customer(9, 'Diego', 'Vargas', 'diego.vargas@testuserbd2.com', 109, TRUE);
CALL insert_customer(10, 'Valentina', 'Mendoza', 'valentina.mendoza@testuserbd2.com', 110, TRUE);

-- Borrar registros insertados por el procedimiento insert_customer
DELETE FROM customer WHERE first_name = 'Juan' AND last_name = 'Pérez' AND email = 'juan.perez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Ana' AND last_name = 'Gómez' AND email = 'ana.gomez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Luis' AND last_name = 'Martínez' AND email = 'luis.martinez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'María' AND last_name = 'López' AND email = 'maria.lopez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Carlos' AND last_name = 'Hernández' AND email = 'carlos.hernandez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Laura' AND last_name = 'Torres' AND email = 'laura.torres@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Javier' AND last_name = 'Ramírez' AND email = 'javier.ramirez@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Sofía' AND last_name = 'Cruz' AND email = 'sofia.cruz@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Diego' AND last_name = 'Vargas' AND email = 'diego.vargas@testuserbd2.com';
DELETE FROM customer WHERE first_name = 'Valentina' AND last_name = 'Mendoza' AND email = 'valentina.mendoza@testuserbd2.com';