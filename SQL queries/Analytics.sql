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


-- Peak listening hour

SELECT 
    DATEPART(HOUR, CAST(ts AS DATETIME2)) AS hour_of_day,
    -- Formats hour nicely (e.g., "14:00 - 14:59 (2 PM)")
    FORMAT(CAST(ts AS DATETIME2), 'HH:00') AS hour_format,
    COUNT(*) AS total_plays,
    ROUND(SUM(hours_played), 2) AS total_hours_played,
    ROUND(SUM(minutes_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_minutes_per_active_day
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATEPART(HOUR, CAST(ts AS DATETIME2)),
    FORMAT(CAST(ts AS DATETIME2), 'HH:00')
ORDER BY 
    total_hours_played DESC;










-- 2. Artist Popularity and Listening Concentration

-- Top 10 Artists by Total Listening Time

SELECT TOP 10
    artist_name,
    ROUND(SUM(hours_played), 2) AS total_hours_played,
    COUNT(*) AS total_plays
FROM spotify_cleaned_dataset
GROUP BY artist_name
ORDER BY total_hours_played DESC;

-- Top 10 Artists by Play Count

SELECT TOP 10
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(hours_played), 2) AS total_hours_played
FROM spotify_cleaned_dataset
GROUP BY artist_name
ORDER BY total_plays DESC;

-- Percentage of Listening Time Contributed by Top 5 Artists

WITH Top5Artists AS (
    SELECT TOP 5
        artist_name,
        SUM(hours_played) AS top5_hours
    FROM spotify_cleaned_dataset
    GROUP BY artist_name
    ORDER BY SUM(hours_played) DESC
)
SELECT 
    ROUND(SUM(top5_hours), 2) AS top_5_total_hours,
    ROUND((SELECT SUM(hours_played) FROM spotify_cleaned_dataset), 2) AS overall_total_hours,
    ROUND(
        (SUM(top5_hours) * 100.0) / (SELECT SUM(hours_played) FROM spotify_cleaned_dataset), 
        2
    ) AS top_5_percentage_contribution
FROM 
    Top5Artists;


-- 3. Song-Level Analysis

-- Top 10 Songs by Total Listening Time


SELECT TOP 10
    track_name,
    artist_name,
    ROUND(SUM(hours_played), 2) AS total_hours_played,
    COUNT(*) AS total_plays
FROM spotify_cleaned_dataset
GROUP BY 
    track_name, 
    artist_name
ORDER BY total_hours_played DESC;


-- Most-Played Songs (Top 10 by Play Count)

SELECT TOP 10
    track_name,
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(hours_played), 2) AS total_hours_played
FROM spotify_cleaned_dataset
GROUP BY 
    track_name, 
    artist_name
ORDER BY 
    total_plays DESC;

-- Songs with Unusually Low Average Listening Duration

SELECT TOP 20
    track_name,
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(AVG(minutes_played), 2) AS avg_minutes_played,
    ROUND(AVG(ms_played / 1000.0), 1) AS avg_seconds_played,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS skip_rate_pct
FROM spotify_cleaned_dataset
GROUP BY 
    track_name, 
    artist_name
HAVING 
    COUNT(*) >= 10 
    AND AVG(minutes_played) < 0.5 -- Average listen time under 30 seconds
ORDER BY 
    avg_minutes_played ASC,
    total_plays DESC;



-- 4. Listening Engagement


-- Overall Skip Rate

SELECT 
    COUNT(*) AS total_plays,
    SUM(CAST(skipped AS INT)) AS total_skips,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS overall_skip_rate_pct
FROM 
    spotify_cleaned_dataset;




--Skip Rate by Hour (Time of Day)


SELECT 
    DATEPART(HOUR, CAST(ts AS DATETIME2)) AS hour_of_day,
    FORMAT(CAST(ts AS DATETIME2), 'HH:00') AS hour_format,
    COUNT(*) AS total_plays,
    SUM(CAST(skipped AS INT)) AS total_skips,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS skip_rate_pct
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATEPART(HOUR, CAST(ts AS DATETIME2)),
    FORMAT(CAST(ts AS DATETIME2), 'HH:00')
ORDER BY 
    hour_of_day ASC;


-- Artists with Highest Skip Rates

SELECT TOP 10
    artist_name,
    COUNT(*) AS total_plays,
    SUM(CAST(skipped AS INT)) AS total_skips,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS skip_rate_pct
FROM 
    spotify_cleaned_dataset
GROUP BY 
    artist_name
HAVING 
    COUNT(*) >= 20
ORDER BY 
    skip_rate_pct DESC,
    total_plays DESC;


-- 5. Weekday vs. Weekend


-- Total Listening Hours

SELECT 
    ROUND(SUM(hours_played), 2) AS total_listening_hours,
    ROUND(SUM(minutes_played), 2) AS total_listening_minutes,
    COUNT(*) AS total_lifetime_plays
FROM 
    spotify_cleaned_dataset;


-- Average Listening Time per Day

SELECT 
    -- Active Days (Days with at least 1 play logged)
    ROUND(SUM(hours_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_hours_per_active_day,
    ROUND(SUM(minutes_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_minutes_per_active_day,
    
    -- Calendar Days (Entire account lifespan from first stream to last stream)
    ROUND(SUM(hours_played) / (DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1.0), 2) AS avg_hours_per_calendar_day,
    
    COUNT(DISTINCT CAST(ts AS DATE)) AS total_active_days,
    DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1 AS total_calendar_days
FROM 
    spotify_cleaned_dataset;



-- Number of Plays per Day

SELECT 
    DATENAME(WEEKDAY, CAST(ts AS DATE)) AS day_of_week,
    COUNT(*) AS plays_on_this_day,
    ROUND(SUM(hours_played), 2) AS total_hours_on_this_day
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATENAME(WEEKDAY, CAST(ts AS DATE))
ORDER BY 
    day_of_week DESC





-- 6. Listening Trends and Changes

-- Listening Time by Year 

SELECT 
    YEAR(CAST(ts AS DATETIME2)) AS listening_year,
    COUNT(*) AS total_plays,
    ROUND(SUM(hours_played), 2) AS total_hours_played,
    COUNT(DISTINCT CAST(ts AS DATE)) AS active_days,
    ROUND(SUM(hours_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_hours_per_active_day
FROM 
    spotify_cleaned_dataset
GROUP BY 
    YEAR(CAST(ts AS DATETIME2))
ORDER BY 
    listening_year ASC;

-- Monthly Changes in Listening Activity (Month-over-Month Growth)

WITH MonthlyVolume AS (
    SELECT 
        YEAR(CAST(ts AS DATETIME2)) AS listening_year,
        MONTH(CAST(ts AS DATETIME2)) AS listening_month,
        DATEFROMPARTS(YEAR(CAST(ts AS DATETIME2)), MONTH(CAST(ts AS DATETIME2)), 1) AS month_start_date,
        COUNT(*) AS total_plays,
        ROUND(SUM(hours_played), 2) AS monthly_hours
    FROM 
        spotify_cleaned_dataset
    GROUP BY 
        YEAR(CAST(ts AS DATETIME2)),
        MONTH(CAST(ts AS DATETIME2)),
        DATEFROMPARTS(YEAR(CAST(ts AS DATETIME2)), MONTH(CAST(ts AS DATETIME2)), 1)
)
SELECT 
    listening_year,
    listening_month,
    monthly_hours,
    total_plays,
    -- Get previous month's hours
    LAG(monthly_hours) OVER (ORDER BY month_start_date ASC) AS prev_month_hours,
    -- Calculate hour difference
    ROUND(monthly_hours - LAG(monthly_hours) OVER (ORDER BY month_start_date ASC), 2) AS mom_hour_change,
    -- Calculate percentage growth/decline
    ROUND(
        ((monthly_hours - LAG(monthly_hours) OVER (ORDER BY month_start_date ASC)) * 100.0) 
        / NULLIF(LAG(monthly_hours) OVER (ORDER BY month_start_date ASC), 0), 
        2
    ) AS mom_growth_pct
FROM 
    MonthlyVolume
ORDER BY 
    month_start_date ASC;




-- Changes in Favorite Artists Over Time (Top Artist per Year)

WITH AnnualArtistRankings AS (
    SELECT 
        YEAR(CAST(ts AS DATETIME2)) AS listening_year,
        artist_name,
        COUNT(*) AS total_plays,
        ROUND(SUM(hours_played), 2) AS total_hours_played,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(CAST(ts AS DATETIME2)) 
            ORDER BY SUM(hours_played) DESC
        ) AS artist_rank
    FROM 
        spotify_cleaned_dataset
    WHERE 
        artist_name IS NOT NULL
    GROUP BY 
        YEAR(CAST(ts AS DATETIME2)),
        artist_name
)
SELECT 
    listening_year,
    artist_name AS top_artist,
    total_hours_played,
    total_plays
FROM 
    AnnualArtistRankings
WHERE 
    artist_rank = 1
ORDER BY 
    listening_year ASC;