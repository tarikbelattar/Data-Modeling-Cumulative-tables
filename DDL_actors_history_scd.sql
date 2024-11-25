-- ***********************************************************************
-- * Table: actors_history_scd                                             *
-- * Description:                                                         *
-- *   This table implements a Slowly Changing Dimension (SCD) Type 2      *
-- *   strategy for tracking the historical changes in actors' attributes. *
-- *   Each record represents a period during which an actor's            *
-- *   attributes (quality_class and is_active) remained constant.        *
-- *                                                                       *
-- * Columns:                                                              *
-- *   actor_id      TEXT       - Unique identifier for each actor.       *
-- *   actor         TEXT       - Name of the actor.                      *
-- *   quality_class TEXT       - Classification of the actor based on      *
-- *                                performance or other criteria.           *
-- *   is_active     BOOLEAN    - Indicates whether the actor is active     *
-- *                                in the current_year.                    *
-- *   start_date    INTEGER    - The year when the current record becomes *
-- *                                effective (inclusive).                  *
-- *   end_date      INTEGER    - The year when the current record expires   *
-- *                                (inclusive).                             *
-- *   current_year  INTEGER    - The year associated with this record,     *
-- *                                typically the year of update.             *
-- *                                                                       *
-- * Constraints:                                                          *
-- *   PRIMARY KEY (actor_id, start_date) - Ensures that each actor's      *
-- *     historical period is uniquely identified by actor_id and start_date.*
-- *                                                                       *
-- * Usage:                                                                *
-- *   This table is used to maintain a history of changes in actors'        *
-- *   attributes, allowing for accurate temporal queries and historical      *
-- *   reporting.                                                          *
-- ***********************************************************************
CREATE TABLE IF NOT EXISTS actors_history_scd(
    actor_id text,                              -- Unique identifier for each actor
    actor text,                                 -- Name of the actor
    quality_class text,                         -- Classification of the actor
    is_active BOOLEAN,                          -- Active status of the actor in the current year
    start_date INTEGER,                         -- Year when this record becomes effective
    end_date INTEGER,                           -- Year when this record ends
    current_year INTEGER,                       -- Year associated with this record
    primary key(actor_id, start_date)           -- Composite primary key to ensure unique records
);