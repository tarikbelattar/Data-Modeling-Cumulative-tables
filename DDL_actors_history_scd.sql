CREATE TABLE IF NOT EXISTS actors_history_scd(
    actor_id text,
    actor text,
    quality_class text,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER,
    current_year INTEGER,
    primary key(actor_id, start_date)
);
DROP TABLE actors_history_scd