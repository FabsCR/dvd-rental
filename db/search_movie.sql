-- =========================================================
-- Function: search_movie
-- Description: 
--    This function performs a search on the 
--    title of films in the 'film' table. It returns a table with 
--    the film's ID, title, and release year for all films whose 
--    title matches the given search term.
--
-- Parameters:
--    p_titulo (VARCHAR) - The partial or full movie title to be 
--                         used in the search. This search is case insensitive
--
-- Returns:
--    A table with the following columns:
--    - return_film_id (INTEGER): The ID of the film.
--    - return_title (VARCHAR): The title of the film.
--    - r_year (YEAR): The year the film was released.
--
-- Usage Example:
--    SELECT * FROM search_movie('Inception');
--    This will return all films that contain "Inception" in their title.
--
-- =========================================================


CREATE OR REPLACE FUNCTION search_movie(p_titulo VARCHAR)
RETURNS TABLE(
    return_film_id INTEGER,      -- Film's unique ID
    return_title VARCHAR,        -- Film's title
    r_year YEAR                  -- Year the film was released
) SECURITY DEFINER -- this code allows to other users than the owner
				 -- to execute this function with the privileges of the owner	
AS
$$ 
BEGIN
    -- Perform a case-insensitive search on the 'title' column
    RETURN QUERY
    SELECT film_id, title, release_year  -- Select film details
    FROM film  -- From the 'film' table
    WHERE film.title ILIKE '%' || p_titulo || '%';  -- Match titles containing the search term. The ILIKE operator 
												     -- allows an insensitive search
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- TEST CASES
-- ============================================================
SELECT * FROM search_movie('goldfinger');
SELECT * FROM search_movie('magnolia');
SELECT * FROM search_movie('breakfast');
SELECT * FROM search_movie('G');
SELECT * FROM search_movie(' of ');
SELECT * FROM search_movie('Star');
SELECT * FROM search_movie('Harry');
SELECT * FROM search_movie('In ');
SELECT * FROM search_movie('Matrix');
SELECT * FROM search_movie('mother');