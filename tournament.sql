-- Table definitions for the tournament project.

-- The game tournament will use the Swiss system for pairing up players in each round: 
-- players are not eliminated, and each player should be paired with another player 
-- with the same number of wins, or as close as possible.

-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- The tournament database has tables players and matches;
-- Table matches has unique match ID and winner, loser ID from table players
-- view standing return a table with id, name, wins, total matches
-- view pairing return a table with player pairs with closest ranking for next round
create database tournament;

create table players (ID serial primary key, name text);

create table matches (ID serial primary key, winner integer references players(id),
                    loser integer references players(id));

create view standing 
as select players.ID, name, win, match from players,
(select players.id as id, count(matches.winner) as win from players left join matches 
on players.id = matches.winner group by players.id) as a,
(select players.id as id, count(matches.id) as match from players left join matches 
on players.id = matches.winner or players.id = matches.loser group by players.id) as b
where players.id = a.id and players.id = b.id;

create view pairing as
with ranks as (select id, name, row_number() over (order by win desc, match) as rank from standing)
select a.id as id1, a.name as name1, b.id as id2, b.name as name2 from
ranks as a, ranks as b
where a.rank%2 = 1 and b.rank = a.rank+1;