CREATE TYPE films AS (
    film VARCHAR(100),
    votes integer,
    rating integer,
    filmid text,
    year integer
);

CREATE TYPE quality_class AS
     ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE IF NOT EXISTS actors(
     actor_id text,
     actor text,
     films films[],
     quality_class quality_class,
     current_year INT,
     is_active BOOLEAN,
    PRIMARY KEY (actor_id, current_year)
 );


