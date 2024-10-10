CREATE TABLE fact_alquileres (
    alquiler_id SERIAL PRIMARY KEY,
    fecha_id INTEGER,
    pelicula_id INTEGER,
    tienda_id INTEGER,
    cliente_id INTEGER,
    monto_total DECIMAL(10, 2),
    cantidad_alquileres INTEGER
);


CREATE TABLE dim_peliculas (
    pelicula_id INTEGER PRIMARY KEY,
    titulo VARCHAR(255),
    categoria VARCHAR(100),
    actores TEXT
);

CREATE TABLE dim_lugar (
    tienda_id INTEGER PRIMARY KEY,
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

CREATE TABLE dim_fecha (
    fecha_id INTEGER PRIMARY KEY,
    fecha DATE,
    año INTEGER,
    mes INTEGER,
    dia INTEGER
);

CREATE TABLE dim_clientes (
    cliente_id INTEGER PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(255)
);

INSERT INTO dim_peliculas (pelicula_id, titulo, categoria, actores)
SELECT f.film_id, f.title, c.name AS categoria, STRING_AGG(a.first_name || ' ' || a.last_name, ', ') AS actores
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id, f.title, c.name;

INSERT INTO dim_lugar (tienda_id, ciudad, pais)
SELECT s.store_id, ci.city, co.country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

INSERT INTO dim_fecha (fecha_id, fecha, año, mes, dia)
SELECT DISTINCT
    CAST(TO_CHAR(r.rental_date, 'YYYYMMDD') AS INTEGER) AS fecha_id,  -- Convierte la fecha en formato numérico
    r.rental_date::DATE AS fecha,     -- La fecha completa
    EXTRACT(YEAR FROM r.rental_date) AS año,
    EXTRACT(MONTH FROM r.rental_date) AS mes,
    EXTRACT(DAY FROM r.rental_date) AS dia
FROM rental r;




INSERT INTO fact_alquileres (fecha_id, pelicula_id, tienda_id, cliente_id, monto_total, cantidad_alquileres)
SELECT
    f.fecha_id,
    i.film_id AS pelicula_id,
    r.staff_id AS tienda_id,
    r.customer_id AS cliente_id,
    SUM(p.amount) AS monto_total,
    COUNT(*) AS cantidad_alquileres
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN dim_fecha f ON r.rental_date = f.fecha
GROUP BY f.fecha_id, i.film_id, r.staff_id, r.customer_id;

SELECT p.categoria, SUM(fa.monto_total) AS ingresos_totales
FROM fact_alquileres fa
JOIN dim_peliculas p ON fa.pelicula_id = p.pelicula_id
GROUP BY p.categoria;

