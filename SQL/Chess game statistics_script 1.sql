-- Chess Data analytics script
---Once the data is downloaded and we used R to create the following Database. Please find the R scripts in the "--" files.

	--check if the data is loaded correctly
--Data set 1
SELECT *
FROM chess_games; 

--Data set 2
SELECT *
FROM explorable_data;

--Data set 3: made based on the list of chess openings the user and the opponents used. The opening column was extracted

CREATE TABLE openings AS
SELECT DISTINCT opening
FROM explorable_data;

--onece the list is exported into a csv. Remaining columns were collected from lichess.org and wikipedia and loaded again.

DROP TABLE openings;
 
SELECT *
FROM chess_openings;
----------------

--Amount of game played

SELECT COUNT(*) AS amount_of_games_played, MAX(Date) AS last_date, MIN(Date) AS first_date
FROM explorable_data;

--Table 2: Summary of Live Chess Game Types Played 

SELECT 
    COUNT(*) AS game_amount, 
    TimeClass AS game_type,
    ROUND(COUNT(*) *1.0/ SUM(COUNT(*)) OVER () * 100, 2) AS percentage
FROM explorable_data
GROUP BY 2;

			---From 2405 games played from June 27th, 2018 to March 2nd, 2024, 67 games were blitz, 5 were bullet and 2336 were rapid. 2.6%, 0.21% and 97.13% respectively.
			---Therefore, the focus after will be on rapid games as it is the most played. 97.13% of the time.

CREATE TABLE rapid AS
SELECT Date AS date, 
	   TimeClass AS time_class, 
	   Color AS user_color, 
	   Result AS result, 
	   Rating AS rating, 
	   Moves AS move, 
	   Outcome AS outcome, 
	   Opening AS opening, 
	   Opponent AS opponent
FROM explorable_data
WHERE TimeClass = 'rapid';

						--CHESS GAME STATISTICS
						
--How many rapid games did the user play?

SELECT COUNT(*) AS amount_of_rapid_games_played, MIN(date) AS first_date, MAX(date) AS last_date
FROM rapid;
			---Between February 20th 2023 and March 2nd 2024, 2336 rapid games were played.

--Username: Dindong elo rating over time. How does the users elo rating overtime look?

CREATE TABLE elo_rating AS
SELECT date, ROUND(AVG(rating),2) AS daily_elo
FROM rapid
GROUP BY 1;

--Chess game per result. What does the overall game result look like?

CREATE TABLE total_rapid_game AS
SELECT DISTINCT result AS result, COUNT(result) AS value, ROUND(COUNT(result) *1.0/ SUM(COUNT(result)) OVER () * 100, 2) AS percentage
FROM rapid
GROUP BY 1
ORDER BY 2 DESC;

			

SELECT DISTINCT result AS result, 
	COUNT(result) AS value, 
	ROUND(COUNT(result) * 1.0 / SUM(COUNT(result)) OVER () * 100, 2) AS percentage
FROM rapid
GROUP BY 1

UNION ALL

SELECT 'win_lose_ratio' AS result,
      ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)), 2) AS value,
       NULL AS percentage
FROM rapid
UNION ALL

SELECT 'win_draw_ratio' AS result,
      ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END)), 2) AS value,
       NULL AS percentage
FROM rapid

UNION ALL

SELECT 'loss_draw_ratio' AS result,
      ROUND((SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END)), 2) AS value,
       NULL AS percentage
FROM rapid
ORDER BY value DESC;

			---1128 games resulted in a win (48.29%), where as 1123 games resulted in a loss (48.07%) and 85 games in a draw (3.64%).
			---The user won 13.27 times more games than incurring a draw while 13.21 times more loss. The amount of winning and losses are quite close to each other with a slight amount of more wins.
			
	
--Amount of chess games by color: How many times did the user play as white, and how many times did the user play as black?

CREATE TABLE w_b_ratio AS 	 
SELECT
    SUM(CASE WHEN user_color = 'black' THEN 1 ELSE 0 END) AS black,
    SUM(CASE WHEN user_color = 'white' THEN 1 ELSE 0 END) AS white,
	ROUND((SUM(CASE WHEN user_color = 'black' THEN 1 ELSE 0 END) * 1.0/SUM(CASE WHEN user_color = 'white' THEN 1 ELSE 0 END)),2) AS ratio,
    COUNT(*) AS total
FROM rapid;

--Result amount by color: How many times did I win, lose and draw while playing each color?
CREATE TABLE win_lose_draw_color AS
SELECT 
    user_color,
    SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS win,
    SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS loss,
    SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS draw
FROM rapid
WHERE user_color IN ('white', 'black')
GROUP BY user_color;

--Average rating: What is the overall average user and opponent rating?

SELECT date, ROUND(AVG(opponentRating),2) AS opponent_average
FROM chess_games
GROUP BY 1
HAVING timeClass='rapid';


CREATE TABLE average AS
SELECT ROUND(AVG(daily_elo),2) AS daily_user_average, ROUND(AVG(opponent_average),2) AS daily_opponent_average
FROM(
	SELECT *
	FROM elo_rating AS c1
	LEFT JOIN 
		(SELECT date, ROUND(AVG(opponentRating),2) AS opponent_average
		FROM chess_games
		GROUP BY 1
		HAVING timeClass='rapid') AS c2
	ON c1.rowid=c2.rowid) AS c4;

----
	


