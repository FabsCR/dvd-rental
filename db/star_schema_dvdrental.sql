-- Script to create the star schema for analyzing DVD rentals in the dvdrental database
-- This script includes the creation of fact and dimension tables, and stored procedures for data population.

-- 1. Dimension Table: Film
-- This table stores information about films, including the film title, category, and associated actors.
CREATE TABLE dim_film (
    film_id INT PRIMARY KEY,    -- Film ID, references the original 'film' table in the transactional database
    title VARCHAR(255),         -- Title of the film
    category VARCHAR(100),      -- Film category, such as Action, Comedy, etc.
    actor_name VARCHAR(255)     -- Actor name (concatenated list of actors from 'actor' table)
);

-- 2. Dimension Table: Address
-- This table captures the hierarchical structure of locations, with information on cities and countries.
CREATE TABLE dim_address (
    address_id INT PRIMARY KEY,   -- Address ID, references the original 'address' table
    country VARCHAR(100),         -- Country name (retrieved from 'country' table)
    city VARCHAR(100)             -- City name (retrieved from 'city' table)
);

-- 3. Dimension Table: Rental Date
-- This table stores date-related information, including the hierarchy of year, month, and day.
CREATE TABLE dim_rental_date (
    rental_date DATE PRIMARY KEY,   -- Rental date, this is the main key
    year INT,                       -- Year part of the date
    month INT,                      -- Month part of the date
    day INT                         -- Day part of the date
);

-- 4. Dimension Table: Store
-- This table stores information about the rental stores.
CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,       -- Store ID, references the 'store' table
    store_name VARCHAR(100)         -- Name of the store
);

-- 5. Fact Table: Rentals
-- This table stores aggregated measures for rentals, including the number of rentals and total revenue.
-- It references the dimension tables and captures the metrics of interest.
CREATE TABLE fact_rentals (
    rental_id SERIAL PRIMARY KEY,   -- Surrogate key for the fact table
    film_id INT REFERENCES dim_film(film_id),           -- Foreign key referencing the Film dimension
    address_id INT REFERENCES dim_address(address_id),  -- Foreign key referencing the Address dimension
    store_id INT REFERENCES dim_store(store_id),        -- Foreign key referencing the Store dimension
    rental_date DATE REFERENCES dim_rental_date(rental_date), -- Foreign key referencing the Rental Date dimension
    rental_count INT,                -- Measure: Number of rentals
    total_amount NUMERIC(10, 2)      -- Measure: Total amount collected for rentals
);

-- 6. Stored Procedure: load_fact_rentals
-- This procedure loads data into the fact_rentals table from the transactional rental data.
-- It aggregates rental information by film, address, store, and rental date.
CREATE OR REPLACE FUNCTION load_fact_rentals()
RETURNS VOID AS $$
BEGIN
    -- Insert aggregated rental data into fact_rentals table
    INSERT INTO fact_rentals (film_id, address_id, store_id, rental_date, rental_count, total_amount)
    SELECT 
        i.film_id,                    -- Film ID from the 'inventory' table (through the join)
        a.address_id,                 -- Address ID from the 'address' table
        s.store_id,                   -- Store ID from the 'store' table
        r.rental_date,                -- Rental date from the 'rental' table
        COUNT(r.rental_id) AS rental_count,    -- Count the number of rentals
        SUM(p.amount) AS total_amount          -- Sum the amount collected for rentals
    FROM rental r
    JOIN payment p ON r.rental_id = p.rental_id        -- Join with payment to get the total amount
    JOIN customer c ON r.customer_id = c.customer_id   -- Join with customer to get address_id
    JOIN address a ON c.address_id = a.address_id      -- Join with address for the location
    JOIN inventory i ON r.inventory_id = i.inventory_id -- Join with inventory to get film_id
    JOIN store s ON i.store_id = s.store_id            -- Join with store to get store details
    GROUP BY i.film_id, a.address_id, s.store_id, r.rental_date;  -- Group by dimensions
END;
$$ LANGUAGE plpgsql;

-- 7. Stored Procedure: load_dim_film
-- This procedure populates the dim_film table with data from the film, category, and actor tables.
-- It uses LEFT JOINs to ensure that all films are included, even if they have no category or actors.
CREATE OR REPLACE FUNCTION load_dim_film()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct films into dim_film along with their category and actors
    INSERT INTO dim_film (film_id, title, category, actor_name)
    SELECT 
        f.film_id,                                -- Film ID from the 'film' table
        f.title,                                  -- Title from the 'film' table
        COALESCE(c.name, 'Unknown') AS category,  -- Category name from 'category' (or 'Unknown' if none)
        COALESCE(STRING_AGG(a.first_name || ' ' || a.last_name, ', '), 'No actors listed') AS actor_name -- Actors or default text
    FROM film f
    LEFT JOIN film_category fc ON f.film_id = fc.film_id     -- Join with film_category (LEFT JOIN to avoid missing films)
    LEFT JOIN category c ON fc.category_id = c.category_id   -- Join with category (LEFT JOIN to avoid missing categories)
    LEFT JOIN film_actor fa ON f.film_id = fa.film_id        -- Join with film_actor
    LEFT JOIN actor a ON fa.actor_id = a.actor_id            -- Join with actor
    GROUP BY f.film_id, f.title, c.name;                     -- Group by film ID, title, and category
END;
$$ LANGUAGE plpgsql;

-- 8. Stored Procedure: load_dim_address
-- This procedure populates the dim_address table with data from the address, city, and country tables.
CREATE OR REPLACE FUNCTION load_dim_address()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct addresses into dim_address with their respective cities and countries
    INSERT INTO dim_address (address_id, city, country)
    SELECT 
        a.address_id,                -- Address ID from the 'address' table
        ci.city,                     -- City name from the 'city' table
        co.country                   -- Country name from the 'country' table
    FROM address a
    JOIN city ci ON a.city_id = ci.city_id          -- Join with city table
    JOIN country co ON ci.country_id = co.country_id; -- Join with country table
END;
$$ LANGUAGE plpgsql;

-- 9. Stored Procedure: load_dim_rental_date
-- This procedure populates the dim_rental_date table with rental date information.
-- It ensures no duplicate dates are inserted using ON CONFLICT DO NOTHING.
CREATE OR REPLACE FUNCTION load_dim_rental_date()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct rental dates into dim_rental_date, with year, month, and day breakdown
    INSERT INTO dim_rental_date (rental_date, year, month, day)
    SELECT 
        DISTINCT r.rental_date,            -- Rental date from the 'rental' table
        EXTRACT(YEAR FROM r.rental_date) AS year,   -- Extract year from the rental date
        EXTRACT(MONTH FROM r.rental_date) AS month, -- Extract month from the rental date
        EXTRACT(DAY FROM r.rental_date) AS day      -- Extract day from the rental date
    FROM rental r
    ON CONFLICT (rental_date) DO NOTHING; -- Avoid inserting duplicate dates
END;
$$ LANGUAGE plpgsql;

-- 10. Stored Procedure: load_dim_store
-- This procedure populates the dim_store table with data from the store table.
CREATE OR REPLACE FUNCTION load_dim_store()
RETURNS VOID AS $$
BEGIN
    -- Insert distinct stores into dim_store with their store names
    INSERT INTO dim_store (store_id, store_name)
    SELECT 
        s.store_id,                   -- Store ID from the 'store' table
        'Store ' || s.store_id AS store_name  -- Store name generated dynamically
    FROM store s;
END;
$$ LANGUAGE plpgsql;

-- 11. Final Data Load Procedure
-- This procedure calls all the loading procedures in the correct order to populate the star schema.
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

-- To execute the loading of the entire star schema, simply call:
-- SELECT load_star_schema();

-- ======================================================================
-- Test Queries and Data Verification
-- ======================================================================

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

-- 6. Check aggregated rental data per film
SELECT film_id, SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY film_id
LIMIT 10;

-- 7. Check aggregated rental data by store
SELECT store_id, SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY store_id
LIMIT 10;

-- 8. Check aggregated rental data by year and month
SELECT EXTRACT(YEAR FROM rental_date) AS year, EXTRACT(MONTH FROM rental_date) AS month, 
       SUM(rental_count) AS total_rentals, SUM(total_amount) AS total_revenue
FROM fact_rentals
GROUP BY year, month
LIMIT 10;