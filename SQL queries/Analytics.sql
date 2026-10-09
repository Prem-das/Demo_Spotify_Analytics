
-- Calculating Total_streaming hours and top 5 artist that i listen to
USE Spotify
-- Question no 1:
SELECT 
    DATENAME(weekday, ts) AS day_of_week,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_history
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
    spotify_history
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
    spotify_history
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
    spotify_history
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
    spotify_history
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
    spotify_history;

-- Answer with total span days 
SELECT 
    ROUND(
        SUM(CAST(ms_played AS BIGINT)) / 
        ((DATEDIFF(day, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1) * 3600000.0), 
        2
    ) AS avg_hours_per_calendar_day,
    DATEDIFF(day, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1 AS total_span_days
FROM 
    spotify_history;

-- Questions no 7:

SELECT TOP 1
    CAST(ts AS DATE) AS listening_date,
    DATENAME(weekday, CAST(ts AS DATETIME2)) AS day_of_week,
    COUNT(*) AS total_tracks,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 60000.0, 1) AS total_minutes,
    ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM 
    spotify_history
GROUP BY 
    CAST(ts AS DATE),
    DATENAME(weekday, CAST(ts AS DATETIME2))
ORDER BY 
    total_hours DESC;

-- Question No 8:


SELECT TOP 10
 artist_name,
 ROUND(SUM(CAST(ms_played AS BIGINT)) / 3600000.0, 2) AS total_hours
FROM spotify_history
GROUP BY artist_name
ORDER BY total_hours DESC


-- Question No 9:

