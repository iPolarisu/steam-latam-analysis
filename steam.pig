-- This script finds the actors/actresses that have acted together the most times

-- Input: (id0, id1, friends_since)
friends_raw = LOAD '/data/2023/uhadoop/rucu/steam/friends.csv' USING PigStorage(',') AS (id0, id1, friends_since);

-- Input: (actor, title, year, num, type, episode, billing, char)
users_raw = LOAD '/data/2023/uhadoop/rucu/steam/user_info1.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw2 = LOAD '/data/2023/uhadoop/rucu/steam/user_info2.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw3 = LOAD '/data/2023/uhadoop/rucu/steam/user_info_3.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw4 = LOAD '/data/2023/uhadoop/rucu/steam/user_info4.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw = UNION users_raw, users_raw2;
users_raw = UNION users_raw, users_raw3;
users_raw = UNION users_raw, users_raw4;

-- carga general

steam_users_filtered = FILTER users_raw BY loccountrycode IS NOT NULL AND gameextrainfo IS NOT NULL;



steam_users_nulls_as_category = FOREACH users_raw GENERATE (loccountrycode IS NULL ? 'Desconocido' : loccountrycode) AS loccountrycode, (gameextrainfo IS NULL ? 'Desconocido' : gameextrainfo) AS gameextrainfo, steamid, personaname, lastlogoff, timecreated, gameid, locstatecode, loccityid;

country_game = FOREACH steam_users_filtered GENERATE loccountrycode, gameextrainfo;

grouped = GROUP country_game BY (loccountrycode, gameextrainfo);
counts = FOREACH grouped GENERATE group AS ((loccountrycode, gameextrainfo)), COUNT(country_game) AS num_ocurrencias;
-- Sabemos cuenta de pais-juego actual.

-- analisis de cuenta privada ###

-- analisis juegos con mas amigos jugando al mismo TIEMPO

-- analisis de amistades antiguas.





users_group = GROUP steam_users_nulls_as_category BY (loccountrycode: chararray, gameextrainfo: chararray);
count = FOREACH country_game GENERATE group AS (loccountrycode: chararray, gameextrainfo: chararray), COUNT(steam_users_nulls_as_category) AS count;


-- Line 1: Filter raw to make sure type equals 'THEATRICAL_MOVIE' 
movies = FILTER raw BY type == 'THEATRICAL_MOVIE';

-- Line 2: Generate new relation with full movie name (concatenating title+##+year+##+num) and actor
full_movies = FOREACH movies GENERATE CONCAT(title,'##',year,'##',num), actor;

-- Line 3 + 4: Generate the co-star pairs 
full_movies_alias = FOREACH full_movies GENERATE $0, $1;
movie_actor_pairs = JOIN full_movies BY $0, full_movies_alias by $0;

-- Line 5: filter to ensure that the first co-star is lower alphabetically than the second
movie_actor_pairs_unique = FILTER movie_actor_pairs BY full_movies::actor < full_movies_alias::actor;

-- Line 6: concatenate the co-stars into one column 
simply_actor_pairs = FOREACH movie_actor_pairs_unique GENERATE CONCAT(full_movies::actor,'##',full_movies_alias::actor) AS actor_pair;

-- Line 7: group the relation by co-stars
actor_pairs_grouped = GROUP simply_actor_pairs BY actor_pair;

-- Line 8: count each group of co-stars
actor_pair_count = FOREACH actor_pairs_grouped GENERATE COUNT($1) AS count, group AS actor_pair; 

-- Line 9: order the count in descending order
ordered_actor_pair_count = ORDER actor_pair_count BY count DESC; 

-- output the final count
-- TODO: REPLACE ahogan WITH YOUR FOLDER
STORE ordered_actor_pair_count INTO '/uhadoop2010/rucu/imdb-costars/';

