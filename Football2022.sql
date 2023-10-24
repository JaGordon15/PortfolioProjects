-- I am doing some general analysis of the 2022 Fantasy football season
-- This data comes from https://www.pro-football-reference.com/years/2022/fantasy.htm
-- These queries include all my comments I had while creating them to show some of my thought process and changes made along the way, Jalin Gordon

SELECT *
FROM Football..FB2022

SELECT *
FROM Football..FB2022
WHERE Position = 'QB'

SELECT * 
FROM Football..FB2022
WHERE Position = 'RB'

SELECT * 
FROM Football..FB2022
WHERE Position = 'WR'

SELECT * 
FROM Football..FB2022
WHERE Position = 'TE'


-- Lets start some analysis 

-- Show all QB's
SELECT *
FROM Football..FB2022
WHERE Position = 'QB'
ORDER BY Rank ASC


-- Showing the top players in each position
SELECT * 
FROM Football..FB2022
WHERE  PosRank = 1 and Position is not null

-- Lets see how many points each position has total

SELECT SUM (PPR) as All_QB_Points
FROM Football..FB2022
WHERE Position = 'QB'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'RB'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'WR'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'TE'


-- Lets combine the results into one table
SELECT 'QB' AS Position, SUM(PPR) as Total_Position_Points
FROM Football..FB2022
WHERE Position = 'QB'
UNION ALL
SELECT 'RB' AS Position, SUM(PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'RB'
UNION ALL
SELECT 'WR' AS Position, SUM(PPR) as All_WR_Points
FROM Football..FB2022
WHERE Position = 'WR'
UNION ALL
SELECT 'TE' AS Position, SUM(PPR) as All_TE_Points
FROM Football..FB2022
WHERE Position = 'TE';

-- Looks like WR's are the position that scores the most points
-- followed by RB, then QB then TE


-- Lets find the top 10 players in each position

-- this works but the data is in one list, might be beter to just do separate queries and visulizing in tableau
SELECT Name, PosRank, Position, PPR
FROM Football..FB2022
WHERE PosRank <= 10 And PPR IS NOT NULL
ORDER BY Position, PosRank


-- Lets get the number of players in each position
SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'QB'
-- 72 Qbs

SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'RB'
-- 139 RBs

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'WR'
--185 WRs

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'TE'
-- 101 TEs

-- Im going to see if there are players that did not get points and make sure they did not slip in the count

SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'QB' AND PPR > 0
-- still 72

SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'RB' AND PPR > 0
-- still 139

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'WR' AND PPR > 0
--185 WRs

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'TE' AND PPR > 0
-- still 101

-- double checked this was correct by selecting all for each position and make sure each player had PPR (They did)

SELECT COUNT (Name)
FROM Football..FB2022
WHERE PPR > 0
-- this confirms only 2 players do not have any points

-- Now lets see how much each position contributes to total points 


SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'QB') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_QB_Points
-- answer is 19.301%

-- Ok that worked now going to use Unions to create one list with all the percentages
-- actually not going to use unions as I think it will be better to visulize having individual queries
	
SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'RB') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_RB_Points
-- answer is 27.118%

SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'WR') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_WR_Points
--answer is 39.284%

SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'TE') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_TE_Points
-- answer is 14.289%


-- Now Im going back to an earlier query but going to be looking at the top 20 players in each position
SELECT Name, PosRank, Position, PPR
FROM Football..FB2022
WHERE PosRank <= 20 And PPR IS NOT NULL
ORDER BY Position, PPR DESC
--General observations:
-- highest QB1 points 417.4 QB20 196.6
-- RB1 372.7 RB20 185.8
--TE1 215.4 TE20 115.6
--WR1 368.7 WR20 199.1

--How far down until the position scored less than 50 points from number1?
--QB: Only top 3 Qbs score within 50 points of number 1
--RB: Again only top 3 Rbs are within 50
--TE: Only top 1. Second is 100 points behind 
--WR: Top 4 are within 50 


--Lets find the rush yards leaders
SELECT TOP 20 Name, Rush_Yds, Position, PosRank, Rush_TD, PPR
FROM Football..FB2022
ORDER BY Rush_Yds DESC
-- Justin Fields was the 7th leading rusher, interesting

--Lets find leading pass catchers
SELECT TOP 20 Name, Rec_Rec, Rec_Yds, Rec_TD, Position
FROM Football..FB2022
ORDER BY Rec_Rec DESC
-- two TE's and two RB's are in the top 20

------------------------------------------------
-- ok lets put queries below that we will be taking to Tableau to visulize

SELECT * 
FROM Football..FB2022
WHERE  PosRank <= 2 and Position is not null
ORDER BY Position
-- this query shows the top two players at each position


SELECT SUM (PPR) as All_QB_Points
FROM Football..FB2022
WHERE Position = 'QB'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'RB'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'WR'

SELECT SUM (PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'TE'
-- These queries show the total points for each position

SELECT 'QB' AS Position, SUM(PPR) as Total_Position_Points
FROM Football..FB2022
WHERE Position = 'QB'
UNION ALL
SELECT 'RB' AS Position, SUM(PPR) as All_RB_Points
FROM Football..FB2022
WHERE Position = 'RB'
UNION ALL
SELECT 'WR' AS Position, SUM(PPR) as All_WR_Points
FROM Football..FB2022
WHERE Position = 'WR'
UNION ALL
SELECT 'TE' AS Position, SUM(PPR) as All_TE_Points
FROM Football..FB2022
WHERE Position = 'TE';
-- this is the same info as last query but in one table

SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'QB' AND PPR > 0
-- still 72

SELECT COUNT (Name)
FROM Football..FB2022
WHERE Position = 'RB' AND PPR > 0
-- still 139

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'WR' AND PPR > 0
--185 WRs

SELECT COUNT (Name)
FROM Football..FB2022
WHERE position = 'TE' AND PPR > 0
-- still 101
-- total players at each position over 0 PPR and in the top 499 of Fantasy Football

SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'QB') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_QB_Points
-- answer is 19.301%

-- Ok that worked now going to use Unions to create one list with all the percentages
-- actually not going to use unions as I think it will be better to visulize having individual queries
	
SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'RB') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_RB_Points
-- answer is 27.118%

SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'WR') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_WR_Points
--answer is 39.284%

SELECT
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0 AND Position = 'TE') /
	(SELECT SUM (PPR) FROM Football..FB2022 WHERE PPR > 0) *100 AS Percent_of_TE_Points
-- answer is 14.289%
-- percentage of points each position contributed out of the total fantasy points

--can I find which team has the most fantasy players in the top 100


SELECT COUNT (Team) AS #_of_players_top_100, Team
FROM Football..FB2022
WHERE Rank <= 100
GROUP BY Team
ORDER BY COUNT (Team) DESC
-- BUF, DAL, JAX, GNB, NOR, and PHI are tied with 5


------------------------------------------------------------------
-- OK going back to do some additional queries to answer question I personally have

--Lets see Yahoo's 2022  Mock draft and see how the top players preformed 
-- 1st round Jonathan Taylor, Christian McCaffrey, Cooper Kupp, Justin Jefferson, Austin Ekeler, Dalvin Cook, Derrick Henery, Ja'Marr Chase, Stefon Diggs, Aaron Jones, Najee Harris, D'Andre Swift

SELECT * 
FROM Football..FB2022
WHERE Name IN ('Jonathan Taylor','Christian McCaffrey', 'Cooper Kupp', 'Justin Jefferson', 'Austin Ekeler', 'Dalvin Cook', 'Derrick Henry', 'Stefon Diggs', 'Aaron Jones', 'Najee Harris', 'Ja''Marr Chase', 'D''Andre Swift')
-- taking a look at their production we can see most were solid players but Kupp, Swift, and Taylor underperformed 
-- if we take a closer look we can see they did not play all their games and we could look further to find they had significant injuries this season
-- Also another analysis we can make from this information is that people with the number 1 pick in their leagues could have had a rough year with Taylor being rated number one by so many but having such a lack in production



-- stat leaders 

-- Passing Yards
SELECT Name, Pass_Yds, PosRank
FROM Football..FB2022
WHERE Pass_Yds > 1000
ORDER BY Pass_Yds DESC

-- rushing yards
SELECT Name, Rush_Yds, PosRank
FROM Football..FB2022
WHERE Rush_Yds > 500
ORDER BY Rush_Yds DESC

-- Receiving Yards
SELECT Name, Rec_Yds, PosRank
FROM Football..FB2022
WHERE Rec_Yds > 200
ORDER BY Rec_Yds DESC