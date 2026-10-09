
import pandas as pd 

df = pd.read_csv('data\spotify_history.csv')

print(df.head())
print(df.describe(include='all'))
print(df.info())
print(df.isnull().sum())
print(df['spotify_track_uri'].nunique())
print(df['platform'].unique())
print(df['artist_name'].nunique())
print(df['album_name'].nunique())
print(df['reason_start'].unique())
print(df['reason_end'].unique())
print(df['shuffle'].unique())
print(df['reason_end'].value_counts())
print(df['track_name'].nunique())
