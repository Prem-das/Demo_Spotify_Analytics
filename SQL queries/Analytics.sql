
-- Calculating Total_streaming hours and top 5 artist that i listen to
USE Spotify
-- Question no 1:
SELECT 
    DATENAME(weekday, ts) AS day_of_week,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATENAME(weekday, ts),
    DATEPART(weekday, ts)
ORDER BY 
    total_hours DESC;


-- Question no 2:


SELECT 
    DATEPART(hour, CAST(ts AS DATETIME2)) AS hour_of_day,
    RIGHT('0' + CAST(DATEPART(hour, CAST(ts AS DATETIME2)) AS VARCHAR(2)), 2) + ':00 - ' + 
    RIGHT('0' + CAST(DATEPART(hour, CAST(ts AS DATETIME2)) AS VARCHAR(2)), 2) + ':59' AS time_window,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATEPART(hour, CAST(ts AS DATETIME2))
ORDER BY 
    total_hours DESC;

-- Question No 3:

SELECT 
    CASE 
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 5 AND 11 THEN 'Morning (5 AM - 11:59 AM)'
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 12 AND 16 THEN 'Afternoon (12 PM - 4:59 PM)'
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 17 AND 21 THEN 'Evening (5 PM - 9:59 PM)'
        ELSE 'Night (10 PM - 4:59 AM)'
    END AS time_of_day,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2) AS track_percentage
FROM 
    spotify_cleaned_dataset
GROUP BY 
    CASE 
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 5 AND 11 THEN 'Morning (5 AM - 11:59 AM)'
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 12 AND 16 THEN 'Afternoon (12 PM - 4:59 PM)'
        WHEN DATEPART(hour, CAST(ts AS DATETIME2)) BETWEEN 17 AND 21 THEN 'Evening (5 PM - 9:59 PM)'
        ELSE 'Night (10 PM - 4:59 AM)'
    END
ORDER BY 
    total_hours DESC;


-- Question No 4:

SELECT 
    DATENAME(month, CAST(ts AS DATETIME2)) AS month_name,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_cleaned_dataset
GROUP BY 
    MONTH(CAST(ts AS DATETIME2)),
    DATENAME(month, CAST(ts AS DATETIME2))
ORDER BY 
    total_hours DESC;


-- Questions no 5:


SELECT 
    DATENAME(weekday, CAST(ts AS DATETIME2)) AS day_of_week,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours,
    COUNT(DISTINCT CAST(ts AS DATE)) AS active_days_count,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / (COUNT(DISTINCT CAST(ts AS DATE)) * 3600000.0), 2) AS avg_hours_per_day
FROM 
    spotify_cleaned_dataset
GROUP BY 
    DATENAME(weekday, CAST(ts AS DATETIME2)),
    DATEPART(weekday, CAST(ts AS DATETIME2))
ORDER BY 
    total_hours ASC;


-- Question No 6:

-- Answer with active days 
SELECT 
    ROUND(
        SUM(CAST(ms_played AS BIGINT)) / (COUNT(DISTINCT CAST(ts AS DATE)) * 3600000.0), 
        2
    ) AS avg_hours_per_active_day,
    COUNT(DISTINCT CAST(ts AS DATE)) AS total_active_days
FROM 
    spotify_cleaned_dataset;

-- Answer with total span days 
SELECT 
    ROUND(
        SUM(CAST(ms_played AS BIGINT)) / 
        ((DATEDIFF(day, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1) * 3600000.0), 
        2
    ) AS avg_hours_per_calendar_day,
    DATEDIFF(day, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1 AS total_span_days
FROM 
    spotify_cleaned_dataset;

-- Questions no 7:

SELECT TOP 1
    CAST(ts AS DATE) AS listening_date,
    DATENAME(weekday, CAST(ts AS DATETIME2)) AS day_of_week,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 60000.0, 1) AS total_minutes,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_cleaned_dataset
GROUP BY 
    CAST(ts AS DATE),
    DATENAME(weekday, CAST(ts AS DATETIME2))
ORDER BY 
    total_hours DESC;



-- Question No 8:

SELECT TOP 10
    artist_name,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours,
    COUNT(*) AS total_tracks
FROM 
    spotify_cleaned_dataset
WHERE 
    artist_name IS NOT NULL
GROUP BY 
    artist_name
ORDER BY 
    total_hours DESC;


-- Question No 9:


SELECT TOP 10
 artist_name,
 ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM spotify_cleaned_dataset
GROUP BY artist_name
ORDER BY total_hours DESC



-- Questions No. 10:

WITH Top5Artists AS (
    SELECT TOP 5
        artist_name,
        COUNT(*) AS artist_plays,
        SUM(CAST(ms_played AS BIGINT)) AS artist_ms
    FROM 
        spotify_cleaned_dataset
    WHERE 
        artist_name IS NOT NULL
    GROUP BY 
        artist_name
    ORDER BY 
        artist_plays DESC
),
OverallStats AS (
    SELECT 
        COUNT(*) AS total_plays,
        SUM(CAST(ms_played AS BIGINT)) AS total_ms
    FROM 
        spotify_cleaned_dataset
)
SELECT 
    SUM(t.artist_plays) AS top5_total_plays,
    ROUND(SUM(t.artist_plays) * 100.0 / o.total_plays, 2) AS plays_percentage,
    ROUND(SUM(t.artist_ms) / 3600000.0, 2) AS top5_total_hours,
    ROUND(SUM(t.artist_ms) * 100.0 / o.total_ms, 2) AS hours_percentage
FROM 
    Top5Artists t
CROSS JOIN 
    OverallStats o
GROUP BY 
    o.total_plays, 
    o.total_ms;

-- Question No 11:
WITH YearlyArtistRank AS (
    SELECT 
        YEAR(CAST(ts AS DATETIME2)) AS listening_year,
        artist_name,
        COUNT(*) AS total_plays,
        ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(CAST(ts AS DATETIME2)) 
            ORDER BY SUM(CAST(ms_played AS BIGINT)) DESC
        ) AS rank_in_year
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
    total_plays,
    total_hours
FROM 
    YearlyArtistRank
WHERE 
    rank_in_year = 1
ORDER BY 
    listening_year ASC;


-- Question no 12:

SELECT TOP 10
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours,
    -- Converts average milliseconds to minutes
    ROUND(AVG(CAST(ms_played AS FLOAT)) / 60000.0, 2) AS avg_song_duration_minutes
FROM 
    spotify_cleaned_dataset
WHERE 
    artist_name IS NOT NULL
GROUP BY 
    artist_name
HAVING 
    COUNT(*) >= 50 -- Filters out one-off plays for statistical significance
ORDER BY 
    avg_song_duration_minutes DESC;

--  Question No 13:


SELECT 
    SUM(plays) AS top10_total_plays,
    ROUND(SUM(plays) * 100.0 / MAX(total_library_plays), 2) AS top10_plays_percentage,
    ROUND(SUM(hours), 2) AS top10_total_hours,
    ROUND(SUM(hours) * 100.0 / MAX(total_library_hours), 2) AS top10_hours_percentage
FROM (
    SELECT TOP 10
        artist_name,
        COUNT(*) AS plays,
        SUM(CAST(ms_played AS BIGINT)) / 3600000.0 AS hours,
        SUM(COUNT(*)) OVER() AS total_library_plays,
        SUM(SUM(CAST(ms_played AS BIGINT))) OVER() / 3600000.0 AS total_library_hours
    FROM 
        spotify_cleaned_dataset
    WHERE 
        artist_name IS NOT NULL
    GROUP BY 
        artist_name
    ORDER BY 
        plays DESC
) t;


--  Question No 14:
SELECT TOP 10
    artist_name,
    COUNT(*) AS total_plays,
    -- Count rows where Spotify's skipped flag is true
    SUM(CASE WHEN LOWER(CAST(skipped AS VARCHAR(10))) IN ('true', '1') THEN 1 ELSE 0 END) AS skipped_plays,
    -- Calculate skip rate percentage
    ROUND(
        SUM(CASE WHEN LOWER(CAST(skipped AS VARCHAR(10))) IN ('true', '1') THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 
        2
    ) AS skip_rate_percentage,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_cleaned_dataset
WHERE 
    artist_name IS NOT NULL
GROUP BY 
    artist_name
HAVING 
    COUNT(*) >= 50 -- Filters out one-off plays for statistical significance
ORDER BY 
    skip_rate_percentage DESC;

