
											--OUTCOME STATISTICS

SELECT *
FROM rapid;

--What are the distinct outcomes from everygame?

SELECT DISTINCT outcome
FROM rapid;

			---9 types of game outcome
			
--What is the most common outcome in general?


SELECT outcome, COUNT(outcome) AS amount_of_distinct_outcomes, ROUND(COUNT(outcome) *1.0/ SUM(COUNT(outcome)) OVER () * 100, 2) AS percentage
FROM rapid
GROUP BY 1
ORDER BY 2 DESC;

			---Without accounting for the result of the game, color of the user and opening style, in a general sense, 49.44% of all games resulted in resignation followed by 
			---36.39% of checkmates. 
			
--What is the most common outcome when accounting for result?

SELECT outcome, 
	   SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins_per_outcome, 
	   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses_per_outcome, 
	   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws_per_outcome,
	   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS win_lose_ratio_per_outcome
FROM rapid
GROUP BY 1
ORDER BY 2 DESC;

			---The user won more by by checkmate and lost more by resigning. The user won by checkmate 1.28 times where as lost by resignation 1.44 times.

SELECT outcome, 
	   SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins_per_outcome, 
	   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses_per_outcome, 
	   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws_per_outcome,
	   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS win_lose_ratio_per_outcome
FROM rapid
GROUP BY 1
HAVING win_lose_ratio_per_outcome IS NULL
ORDER BY 4 DESC;

			---Most draws happened because of stalemate or repetition followed by insufficient pieces on the board.
			
CREATE TABLE outcome AS
SELECT *
FROM(		
	SELECT outcome, COUNT(outcome) AS amount_of_distinct_outcomes, ROUND(COUNT(outcome) *1.0/ SUM(COUNT(outcome)) OVER () * 100, 2) AS percentage
	FROM rapid
	GROUP BY 1
	ORDER BY 2 DESC) AS c1
JOIN (SELECT outcome, 
		   SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins_per_outcome, 
		   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses_per_outcome, 
		   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws_per_outcome,
		   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS win_lose_ratio_per_outcome
		FROM rapid
		GROUP BY 1
		ORDER BY 2 DESC) AS c2
ON c1.outcome=c2.outcome;

SELECT *
FROM outcome;

--Which openings led to a specific outcome?

CREATE TABLE outcome_per_opening AS
SELECT DISTINCT opening, outcome, COUNT(outcome) AS amount_of_outcome_per_opening,
			SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins_per_outcome, 
		   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses_per_outcome, 
		   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws_per_outcome,
		   ROUND((SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END)*1.0/SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END)),2) AS win_lose_ratio_per_opening_per_outcome
FROM rapid
GROUP BY 1,2
ORDER BY 3 DESC;

CREATE TABLE outcome_per_opening_black AS
SELECT c1.*
FROM outcome_per_opening AS c1
INNER JOIN opening_frequency_black AS c2
ON c1.opening=c2.opening

CREATE TABLE outcome_per_opening_white AS
SELECT c1.*
FROM outcome_per_opening AS c1
INNER JOIN opening_frequency_white AS c2
ON c1.opening=c2.opening

			---Kings pawn opening led to more resignation and checkmates, followed by the philodor defense. For example, a game with the kings pawn opening ended
			---in 199 resignations out of which 121 times the user resigned where as 78 times the the opponent resigned. 0.64 times a game started by the kings pawn opening resulted in 
			---the resignation of the user. 
			

--What's the outcome based on color of the user?

CREATE TABLE outcome_as_black AS
SELECT outcome, COUNT(outcome) AS amount_of_outcome_as_black,
		SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_outcome_per_win, 
		   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_outcome_per_loss, 
		   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_outcome_per_draw
FROM rapid
WHERE user_color='black'
GROUP BY 1
ORDER BY 2 DESC;



			---As a black player the user got checkmated 235 times and ended up checkmating 211 times. While resiged 352 times.

CREATE TABLE outcome_as_white AS
SELECT outcome, COUNT(outcome) AS amount_of_outcome_as_white,
		SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS amount_of_outcome_per_win, 
		   SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS amount_of_outcome_per_loss, 
		   SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS amount_of_outcome_per_draw
FROM rapid
WHERE user_color='white'
GROUP BY 1
ORDER BY 2 DESC;


			---As a white player the user got checkmated 242 times and ended up checkmating 162 times. While resiged 330 times.




