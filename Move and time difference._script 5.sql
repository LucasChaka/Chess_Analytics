
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


CREATE TABLE time_move_ratio AS
SELECT c1.date, 
	   ROUND(AVG(c1.time_difference_in_minutes),2) AS daily_average_time_difference, 
	   ROUND(AVG(c2.move),2) AS daily_average_move,
	   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS daily_win_lose_ratio
FROM play_time_count AS c1
INNER JOIN rapid AS c2
ON c1.ROWID=c2.ROWID
GROUP BY 1;
