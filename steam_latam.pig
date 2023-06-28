-- Steam Latam Users Analysis

-- load friends table, has data on friends relationships between accounts (will use the second one to remove duplicated relations)
-- Input: (id0, id1, friends_since)
friends_raw = LOAD 'uhadoop2023/rucu/friends.csv' USING PigStorage(',') AS (id0, id1, friends_since);
friends_raw2 = LOAD 'uhadoop2023/rucu/friends.csv' USING PigStorage(',') AS (id0, id1, friends_since);

-- load users table, has info on queried steam users (split into multiple parts)
-- Input: (actor, title, year, num, type, episode, billing, char)
users_raw = LOAD 'uhadoop2023/rucu/user_info1.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw2 = LOAD 'uhadoop2023/rucu/user_info2.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw3 = LOAD 'uhadoop2023/rucu/user_info3.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw4 = LOAD 'uhadoop2023/rucu/user_info4.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw5 = LOAD 'uhadoop2023/rucu/user_info5.csv' USING PigStorage(',') AS (steamid: chararray, personaname: chararray, lastlogoff: long, timecreated: long, gameid: chararray, gameextrainfo: chararray, loccountrycode: chararray, locstatecode: chararray, loccityid: int);
users_raw = UNION users_raw, users_raw2;
users_raw = UNION users_raw, users_raw3;
users_raw = UNION users_raw, users_raw4;
users_raw = UNION users_raw, users_raw5;

-- remove duplicated users and count them
users = DISTINCT users_raw;
grouped = GROUP users  ALL;
counted = FOREACH grouped GENERATE COUNT(users_raw) AS num_filas; 
-- distinct users: 452472

-- users per country
country_filtered = FILTER users BY loccountrycode IS NOT NULL;
group_country = GROUP country_filtered By loccountrycode;
country = FOREACH group_country GENERATE group AS loccountrycode, COUNT(country_filtered) as count;
country_count = FOREACH country GENERATE loccountrycode, count;
order_country = ORDER country_count BY count DESC; 

-- most played games by country (at the moment of being queried)
steam_users_filtered = FILTER users BY loccountrycode IS NOT NULL AND gameextrainfo IS NOT NULL;
country_game = FOREACH steam_users_filtered GENERATE loccountrycode, gameextrainfo;
grouped = GROUP country_game BY (loccountrycode, gameextrainfo);
counts = FOREACH grouped GENERATE group AS ((loccountrycode, gameextrainfo)), COUNT(country_game) AS num_ocurrencias;
order_country_game = ORDER counts BY num_ocurrencias DESC; 
count_group = GROUP order_country_game by $0.$0;
max_count_tuple = FOREACH count_group { ordered_tuples = ORDER $1 BY num_ocurrencias DESC; top_tuple = LIMIT ordered_tuples 1; GENERATE $0 AS loccountrycode, top_tuple;};
max_game_country_flatten = FOREACH max_count_tuple GENERATE FLATTEN($1); 
max_game_country = FOREACH max_game_country_flatten GENERATE $0.$0, $0.$1, $1; 

-- removing inverse relationships between friends (id1, id2 <-> id2, id1)
repeated_friends = JOIN friends_raw BY (id0, id1) LEFT OUTER, friends_raw2 BY (id1, id0);
friends_all = FILTER repeated_friends BY $3 is null;
friends = FOREACH friends_all GENERATE $0, $1, $2;

--grouped = GROUP friends  ALL;
--counted = FOREACH grouped GENERATE COUNT(friends) AS num_filas; 
--1017591

friend_right_join = JOIN friends BY $0 right outer, users by steamid; 
full_friend_join = JOIN friend_right_join BY $1 right outer, users by steamid;
friend_info = FOREACH full_friend_join GENERATE $2, $7, $8, $9, $16, $17, $18;

-- pairs of friends playing the same game
friends_game_null_filter = FILTER friend_info BY $2 IS NOT NULL AND $5 IS NOT NULL AND $2 == $5; 
friends_game_group = GROUP friends_game_null_filter by $2;
friends_game_count = FOREACH friends_game_group GENERATE group AS game, COUNT($1) AS count;
friends_game_count_order = ORDER friends_game_count BY count DESC;
friends_game = LIMIT friends_game_count_order 10;

-- friends by country
friends_country_null_filter = FILTER friend_info BY $3 IS NOT NULL AND $6 IS NOT NULL;
friend_country_group = GROUP friends_country_null_filter by ($3, $6);
friend_country_count = FOREACH friend_country_group GENERATE group AS countries, COUNT($1) AS count;
friend_country_alphorder = FOREACH friend_country_count GENERATE ($0.$0 > $0.$1 ? ( CONCAT($0.$1, $0.$0) AS id, $0.$1, $0.$0, $1) : (CONCAT($0.$0, $0.$1) AS id, $0.$0, $0.$1, $1)); 
friend_country_regroup = GROUP friend_country_alphorder BY $0.$0;
friends_country_flatten = FOREACH friend_country_regroup GENERATE $0, FLATTEN($1);

--GROUP NO AGRUPA 

friend_country_order = ORDER friends_country_recount BY $1 DESC;
--grouped = GROUP full_join  ALL;
--counted = FOREACH grouped GENERATE COUNT(full_join) AS num_filas; 
-- 559214

--((AD,AR),{((AD,AR,34))})


-- analisis juegos con mas amigos jugando al mismo TIEMPO

steam_users_nulls_as_category = FOREACH users_raw GENERATE (loccountrycode IS NULL ? 'Desconocido' : loccountrycode) AS loccountrycode, (gameextrainfo IS NULL ? 'Desconocido' : gameextrainfo) AS gameextrainfo, steamid, personaname, lastlogoff, timecreated, gameid, locstatecode, loccityid;


users_group = GROUP steam_users_nulls_as_category BY (loccountrycode: chararray, gameextrainfo: chararray);
count = FOREACH country_game GENERATE group AS (loccountrycode: chararray, gameextrainfo: chararray), COUNT(steam_users_nulls_as_category) AS count;