-- ***********************************************************************
-- * Type: films                                                          *
-- * Description:                                                        *
-- *   A composite type representing detailed information about a film.   *
-- *   Used to store film-related data within the actors table.           *
-- *                                                                     *
-- * Attributes:                                                         *
-- *   - film    VARCHAR(100) - The title of the film.                   *
-- *   - votes   INTEGER       - The number of votes the film has received.*
-- *   - rating  INTEGER       - The average rating of the film.          *
-- *   - filmid  TEXT          - A unique identifier for the film.        *
-- *   - year    INTEGER       - The release year of the film.           *
-- ***********************************************************************

CREATE TYPE films AS (
    film VARCHAR(100), -- The title of the film
    votes INTEGER,     -- The number of votes the film has received
    rating INTEGER,    -- The average rating of the film
    filmid TEXT,       -- A unique identifier for the film
    year INTEGER       -- The release year of the film
);

-- ***********************************************************************
-- * Type: quality_class                                                 *
-- * Description:                                                        *
-- *   An enumerated type representing the classification of an actor     *
-- *   based on performance metrics or other criteria.                   *
-- *                                                                     *
-- * Enumeration Values:                                                 *
-- *   - 'star'     : Exceptional performance                           *
-- *   - 'good'     : Above average performance                        *
-- *   - 'average'  : Satisfactory performance                         *
-- *   - 'bad'      : Below average performance                        *
-- ***********************************************************************

CREATE TYPE quality_class AS
     ENUM ('star', 'good', 'average', 'bad');

-- ***********************************************************************
-- * Table: actors                                                       *
-- * Description:                                                        *
-- *   Stores information about actors, including their filmography,      *
-- *   performance classification, and activity status for each year.     *
-- *   Utilizes composite types for structured data storage.             *
-- *                                                                     *
-- * Columns:                                                            *
-- *   - actor_id       TEXT        : Unique identifier for each actor.  *
-- *   - actor          TEXT        : Name of the actor.                 *
-- *   - films          films[]     : Array of films associated with the  *
-- *                                      actor, using the 'films' type.  *
-- *   - quality_class  quality_class: Classification based on performance.*
-- *   - current_year   INT         : The year the record pertains to.   *
-- *   - is_active      BOOLEAN     : Indicates if the actor was active   *
-- *                                      in the current year.              *
-- *                                                                     *
-- * Constraints:                                                        *
-- *   - PRIMARY KEY (actor_id, current_year) : Ensures uniqueness of   *
-- *     each actor's record for a specific year.                        *
-- *                                                                     *
-- * Usage:                                                              *
-- *   This table is used to track actors' filmographies and performance  *
-- *   classifications on a yearly basis, facilitating historical data    *
-- *   analysis and reporting.                                           *
-- ***********************************************************************

CREATE TABLE IF NOT EXISTS actors (
     actor_id TEXT,                   -- Unique identifier for each actor
     actor TEXT,                      -- Name of the actor
     films films[],                   -- Array of films associated with the actor
     quality_class quality_class,     -- Classification based on performance
     current_year INT,                -- The year the record pertains to
     is_active BOOLEAN,               -- Indicates if the actor was active in the current year
    PRIMARY KEY (actor_id, current_year) -- Composite primary key to ensure unique records per actor per year
);




