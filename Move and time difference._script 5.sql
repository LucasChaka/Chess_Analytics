
						--MOVES AND TIME IT TAKES THE USER TO WIN OR LOSE A GAME 

--Extract the time each game took as well.
											
SELECT date, startTime, endTime 
FROM chess_games 
WHERE timeClass ='rapid';					

SELECT *
FROM play_time;--refer to the R code on how the minutes are extracted. 


SELECT *
FROM rapid AS c1 
INNER JOIN play_time AS c2	
ON c1.ROWID=c2.ROWID
WHERE time_difference_in_minutes LIKE '-%'; --the negative time difference do not make sense. Therefore, the data is going to be managed again in R. 


--The new data table 

SELECT *
FROM play_time_count
WHERE time_difference_in_minutes LIKE '-%';--there are no negative differences now. Therefore, we can drop the first table

SELECT *
FROM play_time_count
WHERE TRIM(date) >= '2023.03.12' AND TRIM(date) >= '2023.04.15';--the time difference as well as the startTime and endTime variables are now corrected.
																
--For example, the following game which had a negative result is now corrected.
SELECT date, startTime, endTime, time_difference_in_minutes
FROM play_time_count 
WHERE gameId = 72403983381.0; 




DROP TABLE play_time


--What is the average move and duration it takes the user to win a game?
---How many moves did it take to win, lose or draw?

CREATE TABLE average_duration_and_move AS
SELECT 
    c2.result, 
    ROUND(AVG(c2.move),2) AS average_move_by_outcome, 
    ROUND(AVG(c1.time_difference_in_minutes),2) AS avg_time_difference_in_minutes
FROM play_time_count AS c1
INNER JOIN rapid AS c2 ON c1.ROWID = c2.ROWID
GROUP BY 1

UNION ALL

SELECT 
    'total_average' AS result,
    ROUND(AVG(c4.move),2) AS total_average_move_against_each_opponent, 
    ROUND(AVG(c3.time_difference_in_minutes),2) AS total_average_time_against_each_opponent
FROM 
    play_time_count AS c3
INNER JOIN 
    rapid AS c4 
ON c3.ROWID = c4.ROWID;


					
					---It took on average 58 moves and 13 minutes for the games to lead to a draw, 29 moves and 8 minutes 37 seconds to lead to a loss and an average of 30 moves and an  average of 8 minutes and 54 seconds to win a game. 
					---Each rapid game takes approximately 8 miutes and 41 seconds on average. Taking about 30 moves approximately.



--How many moves and duration did it take for each outcome?

SELECT outcome, ROUND(AVG(move),2) AS average_move_by_outcome
FROM rapid
GROUP BY 1
ORDER BY 2 DESC;

					---The result is intuitive as the longest game it should take should be those which ended in a time insufficient ones. As it uses all the 10 minutes.

			
SELECT *
FROM play_time_count;


SELECT *
FROM rapid;


CREATE TABLE move_and_time_per_outcome AS
SELECT c2.outcome, ROUND(AVG(c2.move),2) AS average_move_by_outcome, ROUND(AVG(c1.time_difference_in_minutes),2) AS avg_time_difference_in_minutes
FROM play_time_count AS c1
INNER JOIN rapid AS c2
ON c1.ROWID=c2.ROWID
GROUP BY 1
ORDER BY 2 DESC;

					---Therefore, as expected the games that took a lot of moves on average, also took the longest amount of times on average.
					--For example, games which ended in time insufficiency had an average of 77 moves taking about 19 minutes and 36 seconds on average.
					---For example games that ended in checkmate on average took 33 moves taking about 9 minutes on average.


				
--How many moves did each outcome take per result?					
SELECT result, outcome, ROUND(AVG(move),2) AS average_move_per_outcome_per_result, ROUND(AVG(time_difference_in_minutes))AS average_time_per_outcome_per_result
FROM (SELECT *
	  FROM rapid AS c1
	  INNER JOIN play_time_count AS c2	
	  ON c1.ROWID=c2.ROWID) AS c3
GROUP BY 1, 2;		
					
					--On average it took the user 32 moves and 9 minutes to win a game by checkmate and 33 moves and 9 minutes to lose a game by checkmate.

 --How many moves did it take the top toughest opponents to win the game?

CREATE TABLE opponent_duration AS
SELECT c1.opponent, 
	   c1.opponent_rating, 
	   c2.outcome, ROUND(AVG(c2.move),2) AS average_move_per_opponent_per_outcome, 
	   ROUND(AVG(c3.time_difference_in_minutes),2) AS avg_time_difference_in_minutes
FROM(
		SELECT *
		FROM study_opponents
		ORDER BY opponent_rating DESC
		LIMIT 10) AS c1
INNER JOIN rapid AS c2
ON c1.opponent=c2.opponent
INNER JOIN play_time_count AS c3
ON c2.ROWID=c3.ROWID
WHERE c2.result = 'loss'
GROUP BY 1,2,3
ORDER BY 2 DESC;

					---it took DerLandwirt on average, 28 moves and 8 minutes and 30 seconds to end the game with checkmate.
				

				
--How many minutes and moves did each opening took?

CREATE TABLE black_opening_move_and_time_duration AS
SELECT DISTINCT c1.opening, 
	   ROUND(AVG(c1.move),2) AS average_move, 
	   ROUND(AVG(c2.time_difference_in_minutes),2) AS average_time_difference,
	   c4.amount_of_times_opening_was_used,
	   c3.win_lose_ratio,
	   c3.adjusted_win_lose_ratio
FROM rapid AS c1
INNER JOIN 	play_time_count	AS c2
ON c1.ROWID=c2.ROWID
INNER JOIN adjusted_win_lose_black	AS c3
ON c1.opening=c3.black_openings
INNER JOIN opening_frequency_black	AS c4
ON c3.black_openings=c4.opening
GROUP BY 1
ORDER BY 6 DESC;--black openings	

							--perc defense has the highest win/lose ration when adjusted to the amount of usage. It took on average 32 moves and 9 minutes and 13 seconds
							--for the user to win 1.26 times. It was also used 82 times. 


							
CREATE TABLE white_opening_move_and_time_duration AS
SELECT DISTINCT c1.opening, 
	   ROUND(AVG(c1.move),2) AS average_move, 
	   ROUND(AVG(c2.time_difference_in_minutes),2) AS average_time_difference,
	   c4.amount_of_times_opening_was_used,
	   c3.win_lose_ratio,
	   c3.adjusted_win_lose_ratio
FROM rapid AS c1
INNER JOIN 	play_time_count	AS c2
ON c1.ROWID=c2.ROWID
INNER JOIN adjusted_win_lose_white	AS c3
ON c1.opening=c3.white_openings
INNER JOIN opening_frequency_white	AS c4
ON c3.white_openings=c4.opening
GROUP BY 1
ORDER BY 6 DESC;--white openings

							---Center game has the highest adjusted win/lose ratio and takes the user on average 8 minutes to make 29 moves. It leads the user to win 1.4 imes against its opponents.
	---Therefore, from previous analysis, which opening is the best to focus on learning for the user? Answer through visualization of data.

---Depict the relationship between move and time it takes on a scatter plot


CREATE TABLE time_move_rates AS
SELECT c1.date, 
	   ROUND(AVG(c1.time_difference_in_minutes),2) AS daily_average_time_difference, 
	   ROUND(AVG(c2.move),2) AS daily_average_move,
	   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS daily_win_lose_ratio,
	   SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS daily_wins,
	   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS daily_losses,
	   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS daily_draws
FROM play_time_count AS c1
INNER JOIN rapid AS c2
ON c1.ROWID=c2.ROWID
GROUP BY 1;



--Is a large amount of move or time difference correlated with the result? For example, if the user moves a lot is it likely that the user ends up winning the game because he or she dedicates time on the game?


							---Therefore, the above query also depics the total amount of daily wins, daily losses and daily draws. To see the correlation with amount of average moves.



--time of the day analysis.

							---first set 00:00:00 to 05:59:00
							---2nd set 06:00:00 to 11:59:00
							---3rd set 12:00:00 t0 17:59:00
							---4th set 18:00:00 to 23:59:00

SELECT *
FROM(							
		SELECT *,
				CASE
				WHEN TIME(startTime) >= '00:00:00' AND TIME(startTime) < '05:59:00' THEN 'night'
				WHEN TIME(startTime) >= '06:00:00' AND TIME(startTime) < '11:59:00' THEN 'morning'
				WHEN TIME(startTime) >= '12:00:00' AND TIME(startTime) < '17:59:00' THEN 'afternoon'
				ELSE 'evening'
			END AS start_period,
			CASE
				WHEN TIME(endTime) >= '00:00:00' AND TIME(endTime) < '05:59:00' THEN 'night'
				WHEN TIME(endTime) >= '06:00:00' AND TIME(endTime) < '11:59:00' THEN 'morning'
				WHEN TIME(endTime) >= '12:00:00' AND TIME(endTime) < '17:59:00' THEN 'afternoon'
				ELSE 'evening'
			END AS end_period
		FROM play_time_count) AS c1--the query classifies the time of day into four however, there are instances where the games played lie in the classification borders
WHERE start_period != end_period; --this query shows those border periods. Instead of using a case clause to create a variable as "if start_period is afternoon
								  --and end_period is evening, then evening. It is best to only consider the end period as the time of day. Also in cases where the user has abandoned
								  --the game due to other activities, the end_period can capture that better than the start period. However, the element of urgency while playing the game after starting 
								  --the game may not be captured by the end_period.
								  

								  
CREATE TABLE period AS							  
SELECT *,
		CASE
			WHEN TIME(endTime) >= '00:00:00' AND TIME(endTime) < '05:59:00' THEN 'night'
			WHEN TIME(endTime) >= '06:00:00' AND TIME(endTime) < '11:59:00' THEN 'morning'
			WHEN TIME(endTime) >= '12:00:00' AND TIME(endTime) < '17:59:00' THEN 'afternoon'
			ELSE 'evening'
		END AS period
FROM play_time_count;

SELECT *
FROM period;

--which time period has the most amount of games played?

SELECT period, COUNT(period) AS amount_of_games_played, ROUND(COUNT(period) *1.0/ SUM(COUNT(period)) OVER () * 100, 2) AS percentage
FROM period
GROUP BY 1;

						---1024 games were played between 12 o'clock and 18 o'clock accounting for 43.84% of all games.
						
--Does the time of the day affect the users game result?

CREATE TABLE result_by_period AS
SELECT period, 
       result,
       COUNT(period) AS amount_of_games_played, 
       ROUND(COUNT(period) * 1.0 / SUM(COUNT(period)) OVER () * 100, 2) AS percentage
FROM (
    SELECT *
    FROM period AS c1
    INNER JOIN rapid AS c2 
	ON c1.ROWID = c2.ROWID) AS c3
GROUP BY 1,2
ORDER BY 4 DESC;

						---Afternoons have the most losses and wins because games played there are the largest. Therefore, by dividing the amount of result by the amount of games played in the time period
						---For example, loss amount divided by the amount of games all games played in the afternoon. It is possible to know the winning and losing rate based on the time of the day.
						
CREATE TABLE result_rate_per_period AS				
SELECT 
    period,
    ROUND(SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) * 1.0 / COUNT(period),2) AS win_rate,
    ROUND(SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) * 1.0 / COUNT(period),2) AS loss_rate,
    ROUND(SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) * 1.0 / COUNT(period),2) AS draw_rate
FROM (
    SELECT *
    FROM period AS c1
    INNER JOIN rapid AS c2 ON c1.ROWID = c2.ROWID
) AS c3
GROUP BY 1;

						---Based on the above table, playing in the morning has the highest winning rate, as the user is assumed to be focused. The user has a higher losing rate in the evening as the user is tired from his/her daily activity
						---The significance might not be know for known until advanced analysis is conducted through a logistics regression.
