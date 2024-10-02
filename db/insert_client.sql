-- 
-- Procedimiento: insert_customer
-- 
-- Descripción: 
-- Este procedimiento se encarga de insertar un nuevo registro en la tabla 
-- 'customer'. Utiliza una secuencia para generar un 'customer_id' único y 
-- almacena la información del cliente, incluyendo su estado activo.
-- 
-- Parámetros:
--   p_store_id      INTEGER   : ID de la tienda a la que pertenece el cliente.
--   p_first_name    VARCHAR    : Nombre del cliente.
--   p_last_name     VARCHAR    : Apellido del cliente.
--   p_email         VARCHAR    : Dirección de correo electrónico del cliente.
--   p_address_id    INTEGER   : ID de la dirección del cliente.
--   p_active_bool   BOOLEAN   : Indicador de estado activo (TRUE) o inactivo (FALSE).
-- 
-- Uso:
-- Llamar al procedimiento con la siguiente sintaxis:
-- CALL insert_customer(p_store_id, p_first_name, p_last_name, p_email, p_address_id, p_active_bool);
-- 
-- Ejemplo:
-- CALL insert_customer(1, 'Juan', 'Pérez', 'juan.perez@example.com', 101, TRUE);
-- 
CREATE OR REPLACE PROCEDURE insert_customer(	
	IN p_store_id INTEGER,        -- ID de la tienda
	IN p_first_name VARCHAR,      -- Nombre del cliente
	IN p_last_name VARCHAR,       -- Apellido del cliente
	IN p_email VARCHAR,           -- Correo electrónico del cliente
	IN p_address_id INTEGER,      -- ID de la dirección
	IN p_active_bool BOOLEAN      -- Estado activo/inactivo del cliente
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- Inserta un nuevo registro en la tabla 'customer'
	INSERT INTO customer(
		customer_id,               -- ID único del cliente
		store_id, 
		first_name, 
		last_name, 
		email, 
		address_id, 
		activebool,               -- Indica si el cliente está activo
		create_date,              -- Fecha de creación del registro
		last_update,              -- Fecha de la última actualización
		active                    -- Estado del cliente
	)
	VALUES (
		nextval('customer_customer_id_seq'),  -- Obtiene el próximo valor de la secuencia
		p_store_id,
		p_first_name,
		p_last_name,
		p_email,
		p_address_id,
		true,                                -- Se establece como activo por defecto
		CURRENT_DATE,                       -- Establece la fecha de creación como la fecha actual
		CURRENT_TIMESTAMP AT TIME ZONE 'UTC', -- Marca de tiempo de la última actualización en UTC
		1                                   -- Estado activo
	);
END;
$$;


--TEST CALLS
CALL insert_customer(1, 'Juan', 'Pérez', 'juan.perez@example.com', 101, TRUE);
CALL insert_customer(2, 'Ana', 'Gómez', 'ana.gomez@example.com', 102, TRUE);
CALL insert_customer(3, 'Luis', 'Martínez', 'luis.martinez@example.com', 103, TRUE);
CALL insert_customer(4, 'María', 'López', 'maria.lopez@example.com', 104, TRUE);
CALL insert_customer(5, 'Carlos', 'Hernández', 'carlos.hernandez@example.com', 105, TRUE);
CALL insert_customer(6, 'Laura', 'Torres', 'laura.torres@example.com', 106, TRUE);
CALL insert_customer(7, 'Javier', 'Ramírez', 'javier.ramirez@example.com', 107, TRUE);
CALL insert_customer(8, 'Sofía', 'Cruz', 'sofia.cruz@example.com', 108, TRUE);
CALL insert_customer(9, 'Diego', 'Vargas', 'diego.vargas@example.com', 109, TRUE);
CALL insert_customer(10, 'Valentina', 'Mendoza', 'valentina.mendoza@example.com', 110, TRUE);