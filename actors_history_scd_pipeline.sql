-- *******************************************************
-- * Incremental SCD Update for actors_history_scd Table *
-- * Author: [Your Name]                                  *
-- * Date: [Date]                                         *
-- *******************************************************

-- **Purpose:**
-- This SQL pipeline performs an incremental update of the `actors_history_scd` table,
-- implementing Slowly Changing Dimension (SCD) Type 2 logic. It identifies changes in actors'
-- `quality_class` and `is_active` status compared to the previous year (2016) and updates
-- the historical SCD records accordingly.

INSERT INTO actors_history_scd
WITH actors_history AS(
    SELECT
        actor_id,
        actor,
        current_year,
        quality_class,
        LAG(quality_class,1) OVER (partition by actor_id ORDER BY current_year) as previous_quality_class,
        is_active,
        LAG(is_active,1) OVER (partition by actor_id ORDER BY current_year) as previous_is_active
FROM actors
WHERE current_year <= 2016
),
with_change_indicator AS(
    SELECT *,
       CASE
           WHEN quality_class <> previous_quality_class THEN 1
           WHEN is_active <> previous_is_active THEN 1
           ELSE 0
       END as change_indicator
    FROM actors_history
    ),
with_streak AS (
    SELECT *,
       SUM(change_indicator) OVER (PARTITION BY actor_id ORDER BY current_year) AS streak_indicator
FROM with_change_indicator)
    SELECT
        actor_id,
        actor,
        quality_class,
        is_active,
        MIN(current_year) AS start_year,
        MAX(current_year) AS end_year,
        2016 AS current_year
FROM with_streak
--WHERE actor_id = 'nm0000003'
GROUP BY actor_id, streak_indicator, actor, is_active, quality_class
ORDER BY start_year
;
