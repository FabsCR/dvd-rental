-- Create the table 'country' to store country names
CREATE TABLE country (
    country_id SERIAL PRIMARY KEY, -- Primary key for country
    country VARCHAR(50) NOT NULL,  -- Country name
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'city' to store city names linked to a country
CREATE TABLE city (
    city_id SERIAL PRIMARY KEY, -- Primary key for city
    city VARCHAR(50) NOT NULL, -- City name
    country_id INT REFERENCES country(country_id), -- Foreign key to country
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'address' to store customer, employee, or store addresses
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY, -- Primary key for address
    address VARCHAR(100) NOT NULL, -- Main address
    address2 VARCHAR(100), -- Secondary address (optional)
    district VARCHAR(50) NOT NULL, -- District or area
    city_id INT REFERENCES city(city_id), -- Foreign key to city
    postal_code VARCHAR(10), -- Postal code
    phone VARCHAR(20) NOT NULL, -- Phone number
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'store' to store information about stores
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY, -- Primary key for store
    manager_staff_id INT, -- Manager's staff ID
    address_id INT REFERENCES address(address_id), -- Foreign key to address
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'staff' to store staff information
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY, -- Primary key for staff
    first_name VARCHAR(50) NOT NULL, -- Staff first name
    last_name VARCHAR(50) NOT NULL, -- Staff last name
    address_id INT REFERENCES address(address_id), -- Foreign key to address
    email VARCHAR(100), -- Email address
    store_id INT REFERENCES store(store_id), -- Foreign key to store
    active BOOLEAN DEFAULT TRUE, -- Status of the staff (active/inactive)
    username VARCHAR(50) NOT NULL, -- Username for system login
    password VARCHAR(50), -- Password for system login
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'customer' to store customer information
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY, -- Primary key for customer
    store_id INT REFERENCES store(store_id), -- Foreign key to store
    first_name VARCHAR(50) NOT NULL, -- Customer first name
    last_name VARCHAR(50) NOT NULL, -- Customer last name
    email VARCHAR(100), -- Customer email
    address_id INT REFERENCES address(address_id), -- Foreign key to address
    active BOOLEAN DEFAULT TRUE, -- Status of the customer (active/inactive)
    create_date DATE DEFAULT CURRENT_DATE, -- Date when the customer was created
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'category' to store movie categories (genres)
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY, -- Primary key for category
    name VARCHAR(50) NOT NULL, -- Category name
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'film' to store information about movies
CREATE TABLE film (
    film_id SERIAL PRIMARY KEY, -- Primary key for film
    title VARCHAR(255) NOT NULL, -- Film title
    description TEXT, -- Film description
    release_year INT, -- Release year of the film
    language_id INT NOT NULL, -- Language ID (foreign key, not defined here)
    rental_duration INT NOT NULL DEFAULT 3, -- Rental duration in days
    rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99, -- Rental rate
    length INT, -- Film length in minutes
    replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99, -- Replacement cost
    rating VARCHAR(10), -- Film rating (e.g., G, PG, R)
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Last update timestamp
    special_features TEXT, -- Special features of the film
    fulltext TSVECTOR -- Fulltext search data for film
);

-- Create the table 'film_category' to link films to their categories
CREATE TABLE film_category (
    film_id INT REFERENCES film(film_id), -- Foreign key to film
    category_id INT REFERENCES category(category_id), -- Foreign key to category
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Last update timestamp
    PRIMARY KEY(film_id, category_id) -- Composite primary key
);

-- Create the table 'actor' to store information about actors
CREATE TABLE actor (
    actor_id SERIAL PRIMARY KEY, -- Primary key for actor
    first_name VARCHAR(50) NOT NULL, -- Actor first name
    last_name VARCHAR(50) NOT NULL, -- Actor last name
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'film_actor' to link actors to films
CREATE TABLE film_actor (
    actor_id INT REFERENCES actor(actor_id), -- Foreign key to actor
    film_id INT REFERENCES film(film_id), -- Foreign key to film
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Last update timestamp
    PRIMARY KEY(actor_id, film_id) -- Composite primary key
);

-- Create the table 'inventory' to store inventory details of films in stores
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY, -- Primary key for inventory
    film_id INT REFERENCES film(film_id), -- Foreign key to film
    store_id INT REFERENCES store(store_id), -- Foreign key to store
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'rental' to store details of film rentals
CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY, -- Primary key for rental
    rental_date TIMESTAMP NOT NULL, -- Date of rental
    inventory_id INT REFERENCES inventory(inventory_id), -- Foreign key to inventory
    customer_id INT REFERENCES customer(customer_id), -- Foreign key to customer
    return_date TIMESTAMP, -- Return date of the film (optional)
    staff_id INT REFERENCES staff(staff_id), -- Foreign key to staff who handled the rental
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last update timestamp
);

-- Create the table 'payment' to store customer payments for rentals
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY, -- Primary key for payment
    customer_id INT REFERENCES customer(customer_id), -- Foreign key to customer
    staff_id INT REFERENCES staff(staff_id), -- Foreign key to staff
    rental_id INT REFERENCES rental(rental_id), -- Foreign key to rental
    amount DECIMAL(5,2) NOT NULL, -- Amount paid by the customer
    payment_date TIMESTAMP NOT NULL -- Payment date
);