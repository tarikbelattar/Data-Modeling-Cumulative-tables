WITH last_year AS (
    SELECT *
    FROM actors
    WHERE current_year = 1973
),
this_year AS (
    SELECT
        actorid,
        actor,
        year,
        AVG(rating) AS avg_rating,
        ARRAY_AGG(ROW(film, votes, rating, filmid)::films) AS new_films
    FROM actor_films
    WHERE year = 1974
    GROUP BY actorid, actor, year
)
INSERT INTO actors (actor_id, actor, current_year, films, quality_class, is_active)
SELECT
    COALESCE(ty.actorid, ly.actor_id) AS actor_id,
    COALESCE(ty.actor, ly.actor) AS actor,
    1974 AS current_year,
   CASE
            WHEN ly.films IS NULL THEN ty.new_films
            WHEN ty.year IS NOT NULL THEN ly.films || ty.new_films
            ELSE ly.films
        END AS films,
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
    CASE
        WHEN ty.new_films IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active
FROM last_year ly
FULL OUTER JOIN this_year ty
    ON ly.actor_id = ty.actorid;