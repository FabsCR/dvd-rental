
-- ==============================================
-- ROLE creation of REPLICATOR, 
-- OBSERVATIONS: This user is the main user of the replication 
-- instance (REPLICA SERVER) it has the keyword to allow the replication within the 
-- main instance and the replication instance. 
-- is necesary to have login privileges to access the replica instance
-- ==============================================
CREATE ROLE replicator WITH REPLICATION PASSWORD 'replica' LOGIN;


-- ==============================================
-- Anonymous block to grant selection privileges to rental.

-- NOTES: We decided to grant selection all the tables of the database
-- for debuging purposes. We are aware that in a production scenary, 
-- the selection privileges would be grant to an specific user, 
-- not a role in charge of the replication, 
-- and just for the tables it need to read from. 
-- ============================================== 
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Loop through all the tables in the public schema
    FOR r IN 
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public' 
    LOOP
        -- Execution of the script that actually grant selection from all the tables of DVDRENTAL data base
        EXECUTE 'GRANT SELECT ON TABLE public.' || r.tablename || ' TO replicator;';
    END LOOP;
END $$;


-- ==============================================
-- User creation of VIDEO, 
-- OWNERSHIP: all tables, functions and procedures of the database.
-- OBSERVATIONS: video doesnt have LOGIN privileges, the purpose
-- is to protect the tables and data of unwanted deletion
-- ==============================================

CREATE USER video;

-- ==============================================
-- Modification of the ownership of the database,
-- tables, functions and procedures to video
-- ============================================== 

ALTER DATABASE dvdrental OWNER TO video;

-- ==============================================
-- Anonymous block to assign all the table ownership to video
-- ============================================== 

DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Loop that go trough all the tables in the public schema
    FOR r IN 
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public' 
    LOOP
        -- Execution of the script that actually change the ownership of the table
        EXECUTE 'ALTER TABLE public.' || r.tablename || ' OWNER TO video;';
    END LOOP;
END $$;

-- ==============================================
-- Anonymous block to assign all the views ownership to sequences
-- ============================================== 
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT sequencename
        FROM pg_sequences
        WHERE schemaname = 'public'
    LOOP
		 -- Execution of the script that actually change the ownership of the sequence
        EXECUTE 'ALTER SEQUENCE public.' || r.sequencename || ' OWNER TO video;';
    END LOOP;
END $$;

-- ==============================================
-- Anonymous block to assign all the views ownership to views
-- ============================================== 
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT viewname
        FROM pg_views
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER VIEW public.' || r.viewname || ' OWNER TO video;';
    END LOOP;
END $$;

-- ==============================================
-- Anonymous block to assign all the views ownership to functions without arguments
-- ============================================== 

DO $$ 
DECLARE
    r RECORD;
BEGIN

    FOR r IN 
        SELECT proname, oid
        FROM pg_proc
        JOIN pg_namespace nsp ON nsp.oid = pg_proc.pronamespace
        WHERE nsp.nspname = 'public'
    LOOP
        EXECUTE 'ALTER FUNCTION public.' || r.proname || '() OWNER TO video;';
    END LOOP;
END $$;

-- ==============================================
-- Anonymous block to assign all the views ownership to functions with arguments
-- ============================================== 
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, oid, pg_catalog.pg_get_function_arguments(oid) AS args
        FROM pg_proc
        JOIN pg_namespace nsp ON nsp.oid = pg_proc.pronamespace
        WHERE nsp.nspname = 'public' 
    LOOP
        -- Dynamically build and execute the ALTER FUNCTION statement
        EXECUTE 'ALTER FUNCTION public.' || r.proname || '(' || r.args || ') OWNER TO video;';
    END LOOP;
END $$;

-- ==============================================
-- Anonymous block to assign all the views ownership to procedures
-- ============================================== 
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT proname, pg_catalog.pg_get_function_arguments(oid) AS args
        FROM pg_proc
        JOIN pg_namespace nsp ON nsp.oid = pg_proc.pronamespace
        WHERE nsp.nspname = 'public' 
        AND prokind = 'p'  -- 'p' stands for procedure in pg_proc
    LOOP
        EXECUTE 'ALTER PROCEDURE public.' || r.proname || '(' || r.args || ') OWNER TO video;';
    END LOOP;
END $$;



-- ==============================================
-- role creation of the role emp as the template of privileges for employees

-- OWNERSHIP: NONE

-- PRIVILEGES: LOGIN, Execution

-- OBSERVATIONS: This is a template for the employee type of user
-- can search movies, register movie rentals and return movies.
-- the ROLE has LOGIN privileges.
-- ==============================================

CREATE ROLE emp; -- role creation
ALTER ROLE emp WITH LOGIN PASSWORD 'password'; -- Login privileges assignement to emp

-- GRANTS to the functions and procedures  for the role EMP
GRANT EXECUTE ON FUNCTION search_movie(varchar) TO emp;
GRANT EXECUTE ON PROCEDURE register_rent(p_inventory_id INTEGER, p_customer_id INTEGER, p_staff_id INTEGER) TO emp;
GRANT EXECUTE ON PROCEDURE return_movie(p_rental_id INTEGER) TO emp;



-- ==============================================
-- Role creation of the role admin as the template of privileges for store administrator

-- OWNERSHIP: NONE

-- PRIVILEGES: LOGIN, Execution

-- OBSERVATIONS: This is a template for the store administrator type of user
-- can search movies, register movie rentals and return movies, like the employee
-- and it can also register customers

-- the ROLE has LOGIN privileges.
-- ==============================================

CREATE ROLE admin WITH INHERIT LOGIN PASSWORD 'password'; -- role creation with Login privileges assignement to admin
GRANT emp TO admin; -- this line is to "inherit" the privileges from emp to admin  

-- GRANTS to the functions and procedures  for the role ADMIN
GRANT EXECUTE ON FUNCTION search_movie(varchar) TO admin;
GRANT EXECUTE ON PROCEDURE register_rent(p_inventory_id INTEGER, p_customer_id INTEGER, p_staff_id INTEGER) TO admin;
GRANT EXECUTE ON PROCEDURE return_movie(p_rental_id INTEGER) TO admin;
GRANT EXECUTE ON PROCEDURE insert_customer(p_store_id INTEGER, p_first_name VARCHAR, p_last_name VARCHAR,
											p_email VARCHAR, p_address_id INTEGER, p_active_bool BOOLEAN) to admin;



-- ==============================================
-- USER creation of empleado1 with the role emp
-- ==============================================
CREATE USER empleado1;
ALTER USER empleado1 PASSWORD 'pass';
GRANT emp TO empleado1;

-- ==============================================
-- USER creation of administrador1 with the role admin
-- ==============================================
CREATE USER administrador1;
ALTER USER administrador1 PASSWORD 'pass';
GRANT admin TO administrador1;