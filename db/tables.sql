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