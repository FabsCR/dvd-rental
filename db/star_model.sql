-- Creación de la tabla de hechos 'fact_alquileres'
-- Almacena los datos de cada alquiler, incluyendo las medidas 'monto_total' y 'cantidad_alquileres'
CREATE TABLE fact_alquileres (
    alquiler_id SERIAL PRIMARY KEY,  -- Identificador único de cada alquiler
    fecha_id INTEGER,                -- Clave foránea que referencia una fecha en 'dim_fecha'
    pelicula_id INTEGER,             -- Clave foránea que referencia una película en 'dim_peliculas'
    tienda_id INTEGER,               -- Clave foránea que referencia una tienda en 'dim_lugar'
    cliente_id INTEGER,              -- Clave foránea que referencia un cliente en 'dim_clientes'
    monto_total DECIMAL(10, 2),      -- Monto total cobrado por el alquiler
    cantidad_alquileres INTEGER      -- Cantidad de veces que se realizó un alquiler específico
);

-- Creación de la tabla de dimensión 'dim_peliculas'
-- Almacena detalles de cada película, como título, categoría y actores.
CREATE TABLE dim_peliculas (
    pelicula_id INTEGER PRIMARY KEY,  -- Identificador único de cada película
    titulo VARCHAR(255),              -- Título de la película
    categoria VARCHAR(100),           -- Género de la película (por ejemplo, 'Acción', 'Drama')
    actores TEXT                      -- Lista de actores que participan en la película
);

-- Creación de la tabla de dimensión 'dim_lugar'
-- Almacena información sobre la ubicación de las tiendas.
CREATE TABLE dim_lugar (
    tienda_id INTEGER PRIMARY KEY,    -- Identificador único de cada tienda
    ciudad VARCHAR(100),              -- Ciudad donde se encuentra la tienda
    pais VARCHAR(100)                 -- País donde se encuentra la tienda
);

-- Creación de la tabla de dimensión 'dim_fecha'
-- Almacena datos de cada fecha relevante para los alquileres, incluyendo año, mes y día.
CREATE TABLE dim_fecha (
    fecha_id INTEGER PRIMARY KEY,     -- Identificador único de la fecha, en formato YYYYMMDD
    fecha DATE,                       -- Fecha completa del alquiler
    año INTEGER,                      -- Año del alquiler
    mes INTEGER,                      -- Mes del alquiler
    dia INTEGER                       -- Día del mes del alquiler
);

-- Creación de la tabla de dimensión 'dim_clientes'
-- Almacena detalles de los clientes que realizan los alquileres.
CREATE TABLE dim_clientes (
    cliente_id INTEGER PRIMARY KEY,   -- Identificador único de cada cliente
    nombre VARCHAR(100),              -- Nombre completo del cliente
    email VARCHAR(255)                -- Correo electrónico del cliente
);

-- Carga de datos en la tabla de dimensión 'dim_peliculas'
-- Se agrupan los actores de cada película y se asocian con su título y categoría.
INSERT INTO dim_peliculas (pelicula_id, titulo, categoria, actores)
SELECT f.film_id, f.title, c.name AS categoria, STRING_AGG(a.first_name || ' ' || a.last_name, ', ') AS actores
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id, f.title, c.name;

-- Carga de datos en la tabla de dimensión 'dim_lugar'
-- Almacena la información de cada tienda, incluyendo ciudad y país.
INSERT INTO dim_lugar (tienda_id, ciudad, pais)
SELECT s.store_id, ci.city, co.country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- Carga de datos en la tabla de dimensión 'dim_fecha'
-- Convierte la fecha a un formato numérico único 'YYYYMMDD' para 'fecha_id'.
INSERT INTO dim_fecha (fecha_id, fecha, año, mes, dia)
SELECT DISTINCT
    CAST(TO_CHAR(r.rental_date, 'YYYYMMDD') AS INTEGER) AS fecha_id,  -- Convierte la fecha a formato numérico
    r.rental_date::DATE AS fecha,  -- La fecha completa del alquiler
    EXTRACT(YEAR FROM r.rental_date) AS año,  -- Extrae el año de la fecha
    EXTRACT(MONTH FROM r.rental_date) AS mes,  -- Extrae el mes de la fecha
    EXTRACT(DAY FROM r.rental_date) AS dia  -- Extrae el día de la fecha
FROM rental r;

-- Carga de datos en la tabla de dimensión 'dim_clientes'
-- Combina el nombre y apellido de cada cliente y almacena su correo electrónico.
INSERT INTO dim_clientes (cliente_id, nombre, email)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name), c.email
FROM customer c;

-- Carga de datos en la tabla de hechos 'fact_alquileres'
-- Se relacionan las dimensiones de tiempo, películas, tiendas y clientes con los montos de alquiler.
INSERT INTO fact_alquileres (fecha_id, pelicula_id, tienda_id, cliente_id, monto_total, cantidad_alquileres)
SELECT
    f.fecha_id,  -- Referencia a la fecha desde 'dim_fecha'
    i.film_id AS pelicula_id,  -- Referencia a la película desde 'dim_peliculas'
    r.staff_id AS tienda_id,  -- Referencia a la tienda desde 'dim_lugar'
    r.customer_id AS cliente_id,  -- Referencia al cliente desde 'dim_clientes'
    SUM(p.amount) AS monto_total,  -- Suma de los montos cobrados por los alquileres
    COUNT(*) AS cantidad_alquileres  -- Conteo de cuántas veces se realizó un alquiler
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN dim_fecha f ON r.rental_date = f.fecha
GROUP BY f.fecha_id, i.film_id, r.staff_id, r.customer_id;

-- Consulta de prueba para validar los datos cargados en el modelo
-- Se muestra el total de ingresos por categoría de película.
SELECT p.categoria, SUM(fa.monto_total) AS ingresos_totales
FROM fact_alquileres fa
JOIN dim_peliculas p ON fa.pelicula_id = p.pelicula_id
GROUP BY p.categoria;
