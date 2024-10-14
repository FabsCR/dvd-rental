-- Star Schema Implementation for DVD Rental Analysis
-- This script creates the star schema with dimension and fact tables, and handles data updates.
-- It also includes functions to load data from the transactional database, avoiding duplicates.

-- 1. Fact Table: fact_rentals
-- This table stores the main metrics, including rental count and total revenue. 
-- It is linked to the dimension tables via foreign keys.
CREATE TABLE fact_rentals (
    rental_id SERIAL PRIMARY KEY,
    film_id INT REFERENCES dim_film(film_id),
    address_id INT REFERENCES dim_address(address_id),
    store_id INT REFERENCES dim_store(store_id),
    rental_date DATE REFERENCES dim_rental_date(rental_date),
    rental_count INT,               -- Measure: Number of rentals
    total_amount NUMERIC(10, 2)     -- Measure: Total rental revenue
);

-- 2. Dimension Table: dim_film
-- Stores information about films, including title, category, and actors.
CREATE TABLE dim_film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category VARCHAR(100),
    actor_name VARCHAR(255)
);

-- 3. Dimension Table: dim_address
-- Stores hierarchical location data (country and city).
CREATE TABLE dim_address (
    address_id INT PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100)
);

-- 4. Dimension Table: dim_rental_date
-- Stores date-related information (year, month, day).
CREATE TABLE dim_rental_date (
    rental_date DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT
);

-- 5. Dimension Table: dim_store
-- Stores information about rental stores.
CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100)
);

-- 6. Stored Procedure: load_fact_rentals
-- This procedure loads data into the fact_rentals table. 
-- It first deletes any existing data and then inserts the updated data from the transactional database.
CREATE OR REPLACE FUNCTION load_fact_rentals()
RETURNS VOID AS $$
BEGIN
    -- First, delete the existing data to avoid duplications
    DELETE FROM fact_rentals;

    -- Insert new aggregated rental data into fact_rentals table
    INSERT INTO fact_rentals (film_id, address_id, store_id, rental_date, rental_count, total_amount)
    SELECT 
        i.film_id,                    -- Film ID from the 'inventory' table
        a.address_id,                 -- Address ID from the 'address' table
        s.store_id,                   -- Store ID from the 'store' table
        r.rental_date,                -- Rental date from the 'rental' table
        COUNT(r.rental_id) AS rental_count,    -- Count of rentals
        SUM(p.amount) AS total_amount         -- Sum of the total revenue
    FROM rental r
    JOIN payment p ON r.rental_id = p.rental_id        -- Join with payment to get the total amount
    JOIN customer c ON r.customer_id = c.customer_id   -- Join with customer to get address
    JOIN address a ON c.address_id = a.address_id      -- Join with address for the location
    JOIN inventory i ON r.inventory_id = i.inventory_id -- Join with inventory to get film_id
    JOIN store s ON i.store_id = s.store_id            -- Join with store to get store details
    GROUP BY i.film_id, a.address_id, s.store_id, r.rental_date;  -- Group by dimensions
END;
$$ LANGUAGE plpgsql;

-- 7. Stored Procedure: load_dim_film
-- This procedure populates the dim_film table with data from the film, category, and actor tables.
-- It uses ON CONFLICT to avoid duplicate inserts.
CREATE OR REPLACE FUNCTION load_dim_film()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct films along with their category and actors, ignoring duplicates
    INSERT INTO dim_film (film_id, title, category, actor_name)
    SELECT 
        f.film_id,                                -- Film ID from the 'film' table
        f.title,                                  -- Title from the 'film' table
        COALESCE(c.name, 'Unknown') AS category,  -- Category from 'category', or 'Unknown' if missing
        COALESCE(STRING_AGG(a.first_name || ' ' || a.last_name, ', '), 'No actors listed') AS actor_name -- Actors or default
    FROM film f
    LEFT JOIN film_category fc ON f.film_id = fc.film_id     -- Join with film_category
    LEFT JOIN category c ON fc.category_id = c.category_id   -- Join with category
    LEFT JOIN film_actor fa ON f.film_id = fa.film_id        -- Join with film_actor
    LEFT JOIN actor a ON fa.actor_id = a.actor_id            -- Join with actor
    GROUP BY f.film_id, f.title, c.name
    ON CONFLICT (film_id) DO NOTHING;  -- Avoid duplicates
END;
$$ LANGUAGE plpgsql;

-- 8. Stored Procedure: load_dim_address
-- This procedure populates the dim_address table with address data.
-- It uses ON CONFLICT to avoid duplicate inserts.
CREATE OR REPLACE FUNCTION load_dim_address()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct addresses with their city and country, ignoring duplicates
    INSERT INTO dim_address (address_id, city, country)
    SELECT 
        a.address_id,                -- Address ID from the 'address' table
        ci.city,                     -- City from the 'city' table
        co.country                   -- Country from the 'country' table
    FROM address a
    JOIN city ci ON a.city_id = ci.city_id          -- Join with city
    JOIN country co ON ci.country_id = co.country_id -- Join with country
    ON CONFLICT (address_id) DO NOTHING;  -- Avoid duplicates
END;
$$ LANGUAGE plpgsql;

-- 9. Stored Procedure: load_dim_rental_date
-- This procedure populates the dim_rental_date table with rental dates.
-- It uses ON CONFLICT to avoid duplicate inserts.
CREATE OR REPLACE FUNCTION load_dim_rental_date()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct rental dates into dim_rental_date, avoiding duplicates
    INSERT INTO dim_rental_date (rental_date, year, month, day)
    SELECT 
        DISTINCT r.rental_date,            -- Rental date from the 'rental' table
        EXTRACT(YEAR FROM r.rental_date) AS year,   -- Extract year from rental date
        EXTRACT(MONTH FROM r.rental_date) AS month, -- Extract month from rental date
        EXTRACT(DAY FROM r.rental_date) AS day      -- Extract day from rental date
    FROM rental r
    ON CONFLICT (rental_date) DO NOTHING;  -- Avoid duplicates
END;
$$ LANGUAGE plpgsql;

-- 10. Stored Procedure: load_dim_store
-- This procedure populates the dim_store table with store data.
-- It uses ON CONFLICT to avoid duplicate inserts.
CREATE OR REPLACE FUNCTION load_dim_store()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct stores into dim_store with their store names, ignoring duplicates
    INSERT INTO dim_store (store_id, store_name)
    SELECT 
        s.store_id,                   -- Store ID from the 'store' table
        'Store ' || s.store_id AS store_name  -- Generate store name dynamically
    FROM store s
    ON CONFLICT (store_id) DO NOTHING;  -- Avoid duplicates
END;
$$ LANGUAGE plpgsql;

-- 11. Stored Procedure: load_star_schema
-- This procedure calls all the loading procedures to populate the star schema.
-- It first loads the dimension tables, then loads the fact table.
CREATE OR REPLACE FUNCTION load_star_schema()
RETURNS VOID AS $$
BEGIN
    -- Load the dimension tables first
    PERFORM load_dim_film();
    PERFORM load_dim_address();
    PERFORM load_dim_rental_date();
    PERFORM load_dim_store();

    -- Then load the fact table
    PERFORM load_fact_rentals();
END;
$$ LANGUAGE plpgsql;

-- To execute the star schema loading, simply run:
-- SELECT load_star_schema();

-- Testing Queries:
-- 1. Verify data in dim_film
SELECT * FROM dim_film LIMIT 10;

-- 2. Verify data in dim_address
SELECT * FROM dim_address LIMIT 10;

-- 3. Verify data in dim_rental_date
SELECT * FROM dim_rental_date LIMIT 10;

-- 4. Verify data in dim_store
SELECT * FROM dim_store LIMIT 10;

-- 5. Verify data in fact_rentals
SELECT * FROM fact_rentals LIMIT 10;

-- 6. Aggregated rental data by film
SELECT film_id, SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY film_id
LIMIT 10;

-- 7. Aggregated rental data by store
SELECT store_id, SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY store_id
LIMIT 10;

-- 8. Aggregated rental data by year and month
SELECT EXTRACT(YEAR FROM rental_date) AS year, EXTRACT(MONTH FROM rental_date) AS month, 
       SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY year, month
LIMIT 10;