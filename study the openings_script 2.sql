
						--STUDYING THE OPENINGS

SELECT *
FROM chess_openings;

CREATE TABLE sum_of_openings AS
SELECT *
FROM (SELECT COUNT(*) AS amount_of_openings_from_rapid_games
	  FROM chess_openings) AS c1
JOIN (SELECT COUNT(DISTINCT opening) AS amount_of_distinct_openings_in_rapid_data
	  FROM rapid) AS c2
ON c1.rowid=c2.rowid;

		--The data is correct and matching showcasing there are no discrepancies between the chess_opening table and the distinct amount of openings used in rapid games. Although the openings were extracted from 
		--the explorable data it self, it is always best to make sure for quality purpose as the data is the chess openings table is editted also outside of the database.

--How many times did the user use each distinct opening?

SELECT opening, 
	   COUNT(*) AS amount_of_times_opening_was_used,
	   ROUND(COUNT(*) *1.0/ SUM(COUNT(*)) OVER () * 100, 2) AS percentage
FROM rapid
GROUP BY 1
ORDER BY 2 DESC;

		--out of all the 2336 games, Kings Pawn Opening was used majority of the time which was about 420 times, 17.98 % of the time.
		--However, we didn't make any color diferentiation as the openings used matter based on the color of the opening. For example, Vienna game is associated with 
		--a white opening as it emphasizes on attack, where as Caro-Kann defense is a black opening as it emphasizes on defense.

SELECT c1.opening, c1.amount_of_times_opening_was_used, c1.percentage, c2.Color AS opening_color
FROM (SELECT opening, 
	   COUNT(*) AS amount_of_times_opening_was_used,
	   ROUND(COUNT(*) *1.0/ SUM(COUNT(*)) OVER () * 100, 2) AS percentage
	   FROM rapid
       GROUP BY 1) AS c1
INNER JOIN chess_openings AS c2
ON c1.opening=c2.opening
ORDER BY 2 DESC;

		
		--to visualize the query, it's best to separate the table based on the color of the opening

CREATE TABLE opening_frequency_black AS		
SELECT c1.opening, c1.amount_of_times_opening_was_used, c1.percentage, c2.Color AS opening_color
FROM (SELECT opening, 
	   COUNT(*) AS amount_of_times_opening_was_used,
	   ROUND(COUNT(*) *1.0/ SUM(COUNT(*)) OVER () * 100, 2) AS percentage
	   FROM rapid
       GROUP BY 1) AS c1
INNER JOIN chess_openings AS c2
ON c1.opening=c2.opening
WHERE c2.Color = 'Black'
ORDER BY 2 DESC;


CREATE TABLE opening_frequency_white AS	
SELECT c1.opening, c1.amount_of_times_opening_was_used, c1.percentage, c2.Color AS opening_color
FROM (SELECT opening, 
	   COUNT(*) AS amount_of_times_opening_was_used,
	   ROUND(COUNT(*) *1.0/ SUM(COUNT(*)) OVER () * 100, 2) AS percentage
	   FROM rapid
       GROUP BY 1) AS c1
INNER JOIN chess_openings AS c2
ON c1.opening=c2.opening
WHERE c2.Color = 'White'
ORDER BY 2 DESC;	


---

--How many times did the user win, lose and draw with a specific opening (accounting for the color of the opening)?


SELECT *
FROM opening_frequency_black;


SELECT c1.opening, c1.result, c2.color
FROM rapid AS c1
INNER JOIN chess_openings AS c2
ON c1.opening=c2.Opening
WHERE c2.Color = 'Black';


CREATE TABLE result_per_black_opening AS
SELECT 
    c4.opening AS black_openings, 
    c4.result,
    SUM(CASE WHEN c4.result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins,
    SUM(CASE WHEN c4.result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses,
    SUM(CASE WHEN c4.result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws
FROM (
    SELECT c1.opening, c1.result, c2.color
    FROM rapid AS c1
    INNER JOIN chess_openings AS c2 ON c1.opening = c2.Opening
    WHERE c2.Color = 'Black'
) AS c4
GROUP BY 1, 2
ORDER BY 3 DESC;


CREATE TABLE result_per_white_opening AS
SELECT 
    c4.opening AS white_openings, 
    c4.result,
    SUM(CASE WHEN c4.result = 'win' THEN 1 ELSE 0 END) AS amount_of_wins,
    SUM(CASE WHEN c4.result = 'loss' THEN 1 ELSE 0 END) AS amount_of_losses,
    SUM(CASE WHEN c4.result = 'draw' THEN 1 ELSE 0 END) AS amount_of_draws
FROM (
    SELECT c1.opening, c1.result, c2.color
    FROM rapid AS c1
    INNER JOIN chess_openings AS c2 ON c1.opening = c2.Opening
    WHERE c2.Color = 'White'
) AS c4
GROUP BY 1, 2
ORDER BY 3 DESC;


--What is the winning multiple of each opening? Hence the win/lose ratio?


SELECT *
FROM result_per_black_opening;

CREATE TABLE win_lose_ratio_black_opening AS
SELECT black_openings, SUM(amount_of_wins) AS amount_of_wins, SUM(amount_of_losses) AS amount_of_losses,
		ROUND(SUM(amount_of_wins)*1.0 / SUM(amount_of_losses), 2) AS win_lose_ratio
FROM result_per_black_opening
GROUP BY 1
ORDER BY 4 DESC;

			---The Englund Gambit, Alekhines Defense and Modern defense are the openings with the biggest winning rate at 3.0, 2.14, 2.6 respectively.

SELECT *
FROM result_per_white_opening;

CREATE TABLE win_lose_ratio_white_opening AS
SELECT white_openings, SUM(amount_of_wins) AS amount_of_wins, SUM(amount_of_losses) AS amount_of_losses,
		ROUND(SUM(amount_of_wins)*1.0 / SUM(amount_of_losses), 2) AS win_lose_ratio
FROM result_per_white_opening
GROUP BY 1
ORDER BY 4 DESC;

			------Declining the queens Gambit, Birds opening and Modern defense are the openings with the biggest winning rate at 3.0, 2.14, 2.6 respectively.
			--??? queen's gambit declined is not a white opening. However, The response to the decline goes white as a new opener as well. CHECK AGAIN!!! 
SELECT *
FROM chess_openings;

			---The win/lose ratio doesn't adjust to the amount being used. Less frequent openings are scored higher where as high frequent openings are scored lower.
			---For this reason, it should be neccessary to penalize the score and adjust to the frequency of usage. The formula is log(win_lose_ratio)*amount_of_times_opening_was_used
			---the natural logarithm penalizes the higher scores.
			---By multiplying it to the frequency of usage, it is now possible to view which openings have a higher score.
			---The transformation is coducted in R as the natural log function is not available in SQLite3.

			
			

CREATE TABLE adjusted_win_lose_black AS	
SELECT black_openings, amount_of_wins, amount_of_losses, win_lose_ratio, ROUND(adjusted_win_los_ratio,2) AS adjusted_win_lose_ratio
FROM w_l_ratio_black;

DROP TABLE w_l_ratio_black

CREATE TABLE adjusted_win_lose_white AS	
SELECT white_openings, amount_of_wins, amount_of_losses, win_lose_ratio, ROUND(adjusted_win_los_ratio,2) AS adjusted_win_lose_ratio
FROM w_l_ratio_white;


DROP TABLE w_l_ratio_white


