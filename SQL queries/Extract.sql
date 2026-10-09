CREATE DATABASE Spotify

USE Spotify
DROP TABLE IF EXISTS spotify_history;

CREATE TABLE spotify_history (
    spotify_track_uri VARCHAR(100),
    ts DATETIME2,
    platform VARCHAR(100),
    ms_played INT,
    track_name VARCHAR(MAX),
    artist_name VARCHAR(255),
    album_name VARCHAR(500),
    reason_start VARCHAR(100),
    reason_end VARCHAR(100),
    shuffle VARCHAR(10),
    skipped VARCHAR(10)
);

BULK INSERT spotify_history
FROM 'C:\Users\premk\OneDrive\Documents\spotify_analytics\spotify_history.csv'

WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);