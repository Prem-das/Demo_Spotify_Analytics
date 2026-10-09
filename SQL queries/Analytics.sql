-- 1. Listening Behavior Over Time

-- Total listening hours by month

SELECT 
    MONTH(CAST(ts AS DATETIME2)) AS listening_month,
    DATENAME(MONTH, CAST(ts AS DATETIME2)) AS month_name,
    ROUND(SUM(hours_played), 2) AS total_hours
FROM 
    spotify_cleaned_dataset
GROUP BY 
    MONTH(CAST(ts AS DATETIME2)),
    DATENAME(MONTH, CAST(ts AS DATETIME2))
ORDER BY 
    listening_month ASC;


-- Average daily listening time

-- Considering only the active days here

SELECT 
    COUNT(DISTINCT CAST(ts AS DATE)) AS total_active_days,
    ROUND(SUM(hours_played), 2) AS total_lifetime_hours,
    ROUND(SUM(hours_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_hours_per_day,
    ROUND(SUM(minutes_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_minutes_per_day
FROM 
    spotify_cleaned_dataset;


-- Considering everyday

SELECT 
    -- Calculates total calendar days between first and last stream (inclusive)
    DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1 AS total_calendar_days,
    ROUND(SUM(hours_played), 2) AS total_lifetime_hours,
    
    -- Divides total time by every single day in that date range
    ROUND(SUM(hours_played) / (DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1.0), 2) AS avg_hours_per_calendar_day,
    ROUND(SUM(minutes_played) / (DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1.0), 2) AS avg_minutes_per_calendar_day
FROM 
    spotify_cleaned_dataset;



-- Most active day of the week

SELECT 
    DATENAME(WEEKDAY, CAST(ts AS DATETIME2)) AS day_of_week,
    COUNT(DISTINCT CAST(ts AS DATE)) AS active_days_count,
    ROUND(SUM(hours_played), 2) AS total_hours_played
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATENAME(WEEKDAY, CAST(ts AS DATETIME2))
ORDER BY 
    ROUND(SUM(hours_played), 2) DESC