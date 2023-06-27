DELETE FROM Friends
WHERE steamid_a NOT IN (SELECT steamid FROM Player_Summaries WHERE loccountrycode IN ('AR', 'BR', 'CL', 'CO', 'CR', 'CU', 'DO', 'EC', 'GT', 'HN', 'MX', 'NI', 'PA', 'PE', 'PY', 'SV', 'UY', 'VE'))
   OR steamid_b NOT IN (SELECT steamid FROM Player_Summaries WHERE loccountrycode IN ('AR', 'BR', 'CL', 'CO', 'CR', 'CU', 'DO', 'EC', 'GT', 'HN', 'MX', 'NI', 'PA', 'PE', 'PY', 'SV', 'UY', 'VE'))

DELETE FROM Player_Summaries
WHERE loccountrycode NOT IN ('AR', 'BR', 'CL', 'CO', 'CR', 'CU', 'DO', 'EC', 'GT', 'HN', 'MX', 'NI', 'PA', 'PE', 'PY', 'SV', 'UY', 'VE')

SELECT *
INTO OUTFILE 'friends.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM Friends

SELECT *
INTO OUTFILE 'player_summaries.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM Player_Summaries
