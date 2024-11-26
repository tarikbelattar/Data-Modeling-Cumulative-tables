-- *******************************************************
-- * Incremental SCD Update for actors_history_scd Table *
-- * Author: [Tarik Bel Attar]                                  *
-- * Date: [25/11/2024]                                         *
-- *******************************************************
WITH
     -- **1. Retrieve Last Year's Active SCD Records**
    -- Selects records from actors_history_scd where the current_year is 2016
    -- and the end_date is also 2016, representing the latest period.
    last_year_scd AS (
    SELECT * FROM actors_history_scd
    WHERE current_year = 2016
    AND end_date = 2016
),
   -- **2. Retrieve Historical SCD Records Prior to Last Year**
    -- Selects historical records where current_year is 2016 but end_date is before 2016,
    -- indicating earlier periods that have been closed.
historical_scd AS (
    SELECT
        actor_id,
        actor,
        quality_class,
        is_active,
        start_date,
        end_date,
        current_year
    FROM actors_history_scd
    WHERE current_year = 2016
    AND end_date < 2016
),
     -- **3. Extract Current Year Actor Data**
    -- Selects all actor records from the actors table for the year 2017,
    -- representing the new incoming data to be integrated.
this_year_data AS (
    SELECT * FROM actors
    WHERE current_year = 2017
),
     -- **4. Identify Unchanged Records**
    -- Determines actors whose quality_class and is_active status remain unchanged
    -- compared to their records in last_year_scd.
unchanged_records AS (
    SELECT
        ts.actor_id,
        ts.actor,
        ts.quality_class,
        ts.current_year,
        ts.is_active,
        ls.start_date,
        ts.current_year AS end_date
    FROM this_year_data ts
    JOIN last_year_scd ls
        ON ls.actor_id = ts.actor_id
    WHERE ts.quality_class::text = ls.quality_class -- Cast ENUM to TEXT
    AND ts.is_active = ls.is_active
),
        -- **5. Identify Changed Records**
    -- Detects actors whose quality_class or is_active status has changed.
    -- For each change, prepares two records:
    --   a) The old record with updated end_date.
    --   b) The new record representing the current state.
changed_records AS (
    SELECT
        ts.actor_id,
        ts.actor,
        UNNEST(ARRAY[
            ROW(
                ls.quality_class,
                ls.is_active,
                ls.start_date,
                ls.end_date
            )::scd_actors_type,
            ROW(
                ts.quality_class,
                ts.is_active,
                ts.current_year,
                ts.current_year
            )::scd_actors_type
        ]) AS records,
        ts.current_year
    FROM this_year_data ts
    LEFT JOIN last_year_scd ls
        ON ls.actor_id = ts.actor_id
    WHERE (ts.quality_class::text <> ls.quality_class -- Cast ENUM to TEXT
      OR ts.is_active <> ls.is_active)
),
     -- **6. Expand Changed Records into Separate Rows**
    -- Transforms the array of changed records into individual rows for insertion.
unnested_changed_records AS (
    SELECT
        actor_id,
        actor,
        (records::scd_actors_type).quality_class,
        (records::scd_actors_type).is_active,
        (records::scd_actors_type).start_date,
        (records::scd_actors_type).end_date,
        current_year
    FROM changed_records
),
    -- **7. Identify New Records**
    -- Captures actors who are present in this_year_data but not in last_year_scd,
    -- indicating new entries that need to be added to the SCD table.
new_records AS (
    SELECT
        ts.actor_id,
        ts.actor,
        ts.quality_class,
        ts.is_active,
        ts.current_year AS start_date,
        ts.current_year AS end_date,
        ls.current_year
    FROM this_year_data ts
    LEFT JOIN last_year_scd ls
        ON ts.actor_id = ls.actor_id
    WHERE ls.actor_id IS NULL
)
-- **8. Combine All Relevant Records for Insertion**
-- Merges historical, unchanged, changed, and new records into a unified dataset
-- using UNION ALL to prepare for insertion into the actors_history_scd table.
SELECT actor_id, actor, quality_class, is_active, start_date, end_date, current_year
    FROM historical_scd

    UNION ALL

    SELECT actor_id,
           actor, quality_class::TEXT, -- Ensuring consistency by casting ENUM to TEXT
           is_active,
           start_date,
           end_date,
           current_year
    FROM unchanged_records

    UNION ALL

    SELECT actor_id,
           actor,
           quality_class::TEXT, -- Ensuring consistency by casting ENUM to TEXT
           is_active,
           start_date,
           end_date,
           current_year
    FROM unnested_changed_records

    UNION ALL

    SELECT actor_id,
           actor,
           quality_class::TEXT, -- Ensuring consistency by casting ENUM to TEXT
           is_active,
           start_date,
           end_date,
           current_year
    FROM new_records;