
						--OPPONENT STATISTICS

--What does the distribution of the opponents and the users rating look like?						

CREATE TABLE opponent_vs_user_distribution AS
SELECT opponent, ROUND(AVG(userRating),2) AS average_user_rating, 
ROUND(AVG(opponentRating),2) AS average_opponent_rating
FROM chess_games
WHERE timeClass='rapid'
GROUP BY 1
ORDER BY 3 DESC;

				---resembels a normal distribution in both cases, without actually noticing if there are outliers or not. 
				---Therefore, in R, the outliers, quantiles and and Interquantile ranges are identified and exported here as a data table.

SELECT *
FROM box_plot; 

--
--How many times did I play each opponent? 
-----How many times did I win, lose or draw against each opponent?

CREATE TABLE study_opponents AS
SELECT c1.opponent, c1.frequency, ROUND(AVG(c2.userRating),2) AS user_rating, ROUND(AVG(c2.opponentRating), 2) AS opponent_rating, 
		c1.amount_of_wins, 
		c1.amount_of_losses, 
		c1.amount_of_draw
FROM
	(SELECT opponent, 
		   COUNT(opponent) AS frequency, 
		   SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins,
		   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses,
		   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draw
	FROM rapid
	GROUP BY 1
	ORDER BY 2 DESC) AS c1
INNER JOIN chess_games AS c2
ON c1.opponent=c2.opponent
GROUP BY 1
ORDER BY 2 DESC;

				---The user played the most with DerLandwirt followed by Manutttee.
				---DerLanwirt is also the highest rated. 
				--The user lost 12 times against Derlandwirrt and won 4 times with no draws.
				
				
--What type of openings were used while playing against the top 10 highly rated players? 


	
SELECT *
FROM study_opponents
ORDER BY opponent_rating DESC
LIMIT 10;	

CREATE TABLE opponents_opening AS
SELECT c4.*, c5.Color AS color_associated_with_opening
FROM
	(SELECT c2.opponent, c1.opening, c1.user_color, c1.result, c1.outcome
	FROM rapid AS c1
	INNER JOIN (SELECT *
				FROM study_opponents
				ORDER BY opponent_rating DESC
				LIMIT 10) AS c2
	ON c1.opponent=c2.opponent) AS c4
INNER JOIN chess_openings AS c5
ON c4.opening=c5.Opening;

--How many times did the user win or lose with each opening against each opponent?

CREATE TABLE opponent_opening_win_lose_rate AS
SELECT opponent, opening, COUNT(opening) AS amount_of_times_each_opening_was_used, result, user_color, color_associated_with_opening
FROM opponents_opening
GROUP BY 1,2, 4
ORDER BY 3 DESC;
