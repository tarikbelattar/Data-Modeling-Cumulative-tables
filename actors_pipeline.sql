-- *******************************************************
-- * Incremental Actors Update Pipeline                   *
-- * Description:                                        *
-- *   This pipeline performs an incremental update by     *
-- *   combining the previous year's data with new        *
-- *   incoming data, updating actors' attributes accordingly.*
-- * Author: [Your Name]                                  *
-- * Date: [Date]                                         *
-- *******************************************************

-- **1. Define Common Table Expressions (CTEs)**

WITH
     -- **a. CTE: `last_year`**
    -- Purpose:
    --   Retrieves all actor records from the `actors` table for the previous year (n-1).
    -- Usage:
    --   Used as the baseline to compare against the incoming data for the current year (n).
    last_year AS (
    SELECT *
    FROM actors
    WHERE current_year = 2016
),
    -- **b. CTE: `this_year`**
    -- Purpose:
    --   Aggregates film data from the `actor_films` table for the current year (2017).
    --   Calculates the average rating and compiles a list of new films for each actor.
    -- Components:
    --   - `actorid`: Unique identifier for the actor.
    --   - `actor`: Actor's name.
    --   - `year`: The year of the film (2017).
    --   - `avg_rating`: Average rating of the actor's films in 2017.
    --   - `new_films`: An array of film records, each containing film details.
this_year AS (
    SELECT
        actorid,
        actor,
        year,
        AVG(rating) AS avg_rating,
        ARRAY_AGG(ROW(film, votes, rating, filmid)::films) AS new_films
    FROM actor_films
    WHERE year = 2017
    GROUP BY actorid, actor, year
)
-- **2. Perform Incremental Update with INSERT INTO ... SELECT**
INSERT INTO actors (actor_id, actor, current_year, films, quality_class, is_active)
SELECT
     -- **a. Actor ID**
    -- Uses `COALESCE` to prioritize `this_year` data; if absent, retains `last_year` ID.
    COALESCE(ty.actorid, ly.actor_id) AS actor_id,
    -- **b. Actor Name**
    -- Uses `COALESCE` to prioritize `this_year` name; if absent, retains `last_year` name.
    COALESCE(ty.actor, ly.actor) AS actor,
    -- **c. Current Year**
    -- Explicitly sets the current year to 2017.
    2017 AS current_year,
      -- **d. Films**
    -- Logic:
    --   - If there are no films in `last_year` (`ly.films IS NULL`), use `this_year`'s new films.
    --   - If `this_year` has film data (`ty.year IS NOT NULL`), concatenate `last_year` films with `this_year` films.
    --   - Otherwise, retain `last_year` films.
   CASE
            WHEN ly.films IS NULL THEN ty.new_films
            WHEN ty.year IS NOT NULL THEN ly.films || ty.new_films
            ELSE ly.films
        END AS films,
    -- **e. Quality Class**
    -- Logic:
    --   - If there are new films (`ty.year IS NOT NULL`), determine `quality_class` based on `avg_rating`.
    --   - Else, retain `last_year`'s `quality_class`.
    CASE
        WHEN ty.year IS NOT NULL THEN
            CASE
                WHEN ty.avg_rating > 8 THEN 'star'
                WHEN ty.avg_rating > 7 THEN 'good'
                WHEN ty.avg_rating > 6 THEN 'average'
                ELSE 'bad'
            END
        ELSE
            CASE
                WHEN ly.quality_class = 'star' THEN 'star'
                WHEN ly.quality_class = 'good' THEN 'good'
                WHEN ly.quality_class = 'average' THEN 'average'
                ELSE 'bad'
            END
    END::quality_class AS quality_class,
    -- **f. Is Active**
    -- Logic:
    --   - If there are new films (`ty.new_films IS NOT NULL`), set `is_active` to TRUE.
    --   - Else, set `is_active` to FALSE.
    CASE
        WHEN ty.new_films IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active
FROM
     -- **g. FULL OUTER JOIN between `last_year` and `this_year`**
    -- Purpose:
    --   - Ensures that all actors from both years are considered.
    --   - Actors present only in `last_year` or only in `this_year` are handled appropriately.
    last_year ly
FULL OUTER JOIN this_year ty
    ON ly.actor_id = ty.actorid;
-- **3. End of Pipeline**