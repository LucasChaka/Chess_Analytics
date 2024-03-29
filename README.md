# Chess Data Analytics: Enhancing chess skills through data analysis(in progress)

## Introduction (to be edited in the end)

Many individuals who grasp the rules of chess but don't engage in it frequently believe that winning solely hinges on tactical maneuvering. However, chess encompasses far more than mere tactics. Opening theories, for example, can lead to swift victories, some unfolding in as few as three moves (such as the scholar's mate). The middle game, after players have strategically positioned their pieces, involves a plethora of tactics and strategies, ranging from basic skewers, forks, and pins to more intricate techniques like zugzwang. These maneuvers often dictate the outcome of the endgame, which may have been foreseen by both players, one, or neither.

A strong opening sets the stage for a robust middle game or endgame. Furthermore, the endgame itself relies heavily on the player's knowledge, focus, and other factors, whether acknowledged at the time or not. However, achieving a favorable endgame result often demands meticulous analysis of each game, aiming to enhance future performance. Such scrutiny involves a detailed review: identifying errors, evaluating effective moves, and preparing for subsequent matches. But what about a macro analysis, which offers a holistic review of all games played by one individual instead of one specific game? This comprehensive approach includes examining all advantageous openings used, common strategies among opponents of similar caliber, as well as the player's strengths, weaknesses, and noteworthy opponents.

While obtaining such data may pose a challenge, particularly with most games occurring without formal recording, recent years, especially post Netflix's limited series, "The Queen's Gambit", have witnessed a surge in chess's popularity, particularly online. Platforms like [chess.com](https://www.chess.com/) and [lichess.org](https://lichess.org) have seen significant subscription increases, resulting in detailed game recordings and insights. [chess.com](https://www.chess.com/) provides opportunities through a PGN format, while web applications such as [chessinsights.xyz](https://chessinsights.xyz/) offer raw data, streamlining analysis processes. This report aims to delve into a player's gameplay, offering macro and holistic perspectives for improvement.

However, individual player analyses have inherent limitations; for instance, the range of chess openings is constrained to the player under scrutiny. Yet, leveraging data from top chess masters can broaden the analytical scope. 

**DISCLAIMER:** For privacy reasons, the player's username remains undisclosed. Analysts interested in conducting similar macro analyses can obtain data from [chessinsights.xyz](https://chessinsights.xyz/). Throughout this report, the player is referenced by the pseudonym *John*.

## Methodology

### Data Collection

The data utilized in this analysis primarily originates from [chessinsights.xyz](https://chessinsights.xyz/), a web application designed for chess enthusiasts and data scientists. Users can input a specific username registered on [chess.com](https://www.chess.com/) to access a comprehensive list of raw data alongside a limited set of visualizations tailored for analytical purposes. These data sets encapsulate a history of live chess games played across different geographical regions or among friends, providing valuable insights into players' performance. It's worth noting that alternative platforms such as [lichess.org](https://lichess.org) also offer similar data accessibility.

Initially, two sets of data were downloaded in CSV format: the raw data (refered to as *chess_games* in the SQL scripts) and a relatively cleaner version, which in the following report will be refered to as the *explorable data*. While the raw data offers a wealth of information and variables, its presentation can be somewhat messy. Conversely, the cleaner dataset, though less extensive, is more organized and easier to navigate. However, it's essential to recognize that certain variables available in the cleaner dataset may not be present in the raw data. Thus, to ensure comprehensive analysis, it's advisable to leverage both datasets in tandem.

The data exported to a CSV file from [chessinsights.xyz](https://chessinsights.xyz/) encompasses various columns (referred to as such for now, as the data is raw and has not yet undergone any ETL processes).

Table 1: Summary of Chess Game Data: Raw and Explorable Data Comparison

| Raw Data Column   | Explorable Data Column | Description                                                                                                         |
|--------------------|------------------------|---------------------------------------------------------------------------------------------------------------------|
| userAccuracy       | Accuracy               | Indicates the player's accuracy, reflecting how closely they adhered to optimal moves as determined by the [chess.com](https://www.chess.com/) engine. |
| opponentAccuracy   | -                      | Reflects the opponent's accuracy, measuring their adherence to optimal moves as determined by the [chess.com](https://www.chess.com/) engine.           |
| gameURL            | GameUrl                | Direct link to the specific game played.                                                                           |
| gameID             | -                      | Unique identifier for the game.                                                                                     |
| timeClass          | TimeClass              | Specifies the game type: rapid (games lasting 10-minutes and above), blitz (games lasting 3-minutes), or bullet (games lasting 1-minute).                                |
| fen                | -                      | Serial key for each game.                                                                                           |
| userColor          | Color                  | Indicates the player's color: white or black.                                                                       |
| userRating         | Rating                 | Player's chess performance rating, refered to commonly as Elo rating.                                                                                  |
| opponent           | Opponent               | Opponent's user ID/name.                                                                                                |
| opponentRating     | -                      | Opponent's ratings.                                                                                                 |
| opponentUrl        | -                      | Link to the opponent's page.                                                                                        |
| result             | Result                 | Outcome of the game: win, loss, or draw.                                                                            |
| date               | Date                   | Date of the game.                                                                                                   |
| openingURL         | -                      | URL displaying theoretical opening moves, generally included in the PGN file.                                                                          |
| opening            | Opening                | Type of theoritical opening employed in the game.                                                                               |
| startTime          | -                      | Start time of the live game.                                                                                        |
| endTime            | -                      | End time of the live game.                                                                                          |
| pgn                | -                      | All theoritical moves made during the game. E.g. e4 e5 N3...etc                                                                                    |
| moveCount          | Moves                  | Total number of moves in the game.                                                                                  |
| outcome            | Outcome                | Specific game outcome, e.g., checkmate, abandonment, resignation, or draw.                                          |

Source: [chessinsights.xyz](https://chessinsights.xyz/)


### Data Preprocessing: The ETL process

Once the initial two datasets are imported locally, as is common with most data, they undergo preprocessing. These datasets are then imported into R-studio to create an SQL database. Please refer to the R code in the GitHub file [Chess Database Setup.R](https://github.com/LucasChaka/Chess_Analytics/blob/cd813ace82649e8cf67aca36db64211f8ca67b58/R/Chess%20Database%20Setup.R). Once the database is created, it is stored in a light SQL version, SQLite, along with its DB Browser.

SQL code 1: The two data sets

```sql
--Data set 1
SELECT *
FROM chess_games; 

--Data set 2
SELECT *
FROM explorable_data;
```
Source: [Chess Database Setup.R](https://github.com/LucasChaka/Chess_Analytics/blob/cd813ace82649e8cf67aca36db64211f8ca67b58/R/Chess%20Database%20Setup.R), [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql)

The first dataset is the raw data, while the explorable data is the second dataset. Once the datasets are loaded in, distinct openings used by *John* are collected from the above data, with additional columns collected separately from [lichess.org](https://lichess.org)'s chess opening study guides, identifying whether the openings are theoretically associated with white or black play, indicating whether players are playing as white or black. Below are random 10 rows of these openings, providing insight into their structure:

Table 2: Random chess openings and their theoritical move.

| Opening                     | Move               | Color  |
|-----------------------------|--------------------|--------|
| Nimzowitsch Larsen Attack   | 1.e4 Nf6 2.Nc3    | White  |
| Philidor Defense            | 1.e4 e5 2.Nf3 d6  | Black  |
| French Defense              | 1.e4 e6           | Black  |
| Queen's Pawn Opening        | 1.d4              | White  |
| Scandinavian Defense        | 1.e4 d5           | Black  |
| Reti Opening                | 1.Nf3             | White  |
| Petrov's Defense            | 1.e4 e5 2.Nf3 Nf6 | Black  |
| Englund Gambit              | 1.d4 e5 2.dxe5 Nc6| Black  |

Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql)

The dataset contains a large volume of data with numerous unnecessary details, necessitating a strategic data cleaning process. Initially, a total of 2405 games were played between June 27th, 2018, and March 2nd, 2024. However, the majority of games played from February 20th, 2023, to March 2nd, 2024, were rapid games (lasting 10 minutes or more). Therefore, only rapid games are extracted from the "TimeClass" variable in the explorable data.

Table 3: Frequency of Chess Game Types

| Amount of games played | TimeClass | Share, in % |
|-------------------------|-----------|------------|
| 64                      | blitz     | 2.66 %     |
| 5                       | bullet    | 0.21 %     |
| 2336                    | rapid     | 97.13 %    |

Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql)

Both the raw data and the explorable data contain the same number of rows, and there are no missing values in the important columns required for analysis. However, columns such as *accuracy*, *userAccuracy*, or *opponentAccuracy* may have missing values due to two primary reasons:

- A paid subscription on [chess.com](https://www.chess.com/) is required to access accuracy measurements, making it difficult to obtain data, especially if *John* doesn't have a full subscription.
- The player may not have utilized the one-time free game review offered by [chess.com](https://www.chess.com/) after the games were played. [chess.com](https://www.chess.com/) provides a one-time daily free game review, which includes *userAccuracy* and *opponentAccuracy* data.

Next, by extracting 8 variables from the explorable data, a new data table called "rapid" is created in the database.

SQL Code 2: Creation of the "rapid" data table

```sql
CREATE TABLE rapid AS
SELECT Date AS date, 
     Color AS user_color, 
     Result AS result, 
     Rating AS rating, 
     Moves AS move, 
     Outcome AS outcome, 
     Opening AS opening, 
     Opponent AS opponent
FROM explorable_data
WHERE TimeClass = 'rapid';
```
Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql)

The columns included in the raw data but not in the explorable data, namely *opponentRating*, *startTime*, and *endTime*, are deemed necessary. However, there is no immediate need to join these columns, as they can be extracted when required at a later point. The memory capacity of the local machine to accommodate one more data table is not an issue. Additionally, a new table named *play_time_count* is created. The creation of this table involves coding in R-studio and querying in SQL. The purpose of the table is to depict the time duration of each chess game played. Initially, the code in [Time length extracted.R](https://github.com/LucasChaka/Chess_Analytics/blob/b766d2e772b84cfcb8cd0fbd637e60131dbba590/R/Time%20length%20extracted.R) was executed to create the data table. Once exported from R-studio to the SQL database, the following SQL code was used:

SQL Code 3: Creation of the "play_time_count" table depicting the time duration of each chess game played

```sql
-- Extract the time each game took
SELECT date, startTime, endTime 
FROM chess_games 
WHERE timeClass ='rapid';					

-- Refer to the R code on how the minutes are extracted 
SELECT *
FROM play_time;

-- Joining tables and managing data
SELECT *
FROM rapid AS c1 
INNER JOIN play_time AS c2	
ON c1.ROWID=c2.ROWID
WHERE time_difference_in_minutes LIKE '-%'; -- Negative time differences do not make sense and will be managed again in R.

-- New data table without negative time differences
SELECT *
FROM play_time_count
WHERE time_difference_in_minutes LIKE '-%'; 

-- Corrected time differences and variables
SELECT *
FROM play_time_count
WHERE TRIM(date) >= '2023.03.12' AND TRIM(date) >= '2023.04.15'; 

-- Example of corrected game with negative result
SELECT date, startTime, endTime, time_difference_in_minutes
FROM play_time_count 
WHERE gameId = 72403983381.0;

DROP TABLE play_time;

SELECT *
FROM play_time_count;
```
Source: [SQL script 5](https://github.com/LucasChaka/Chess_Analytics/blob/b9c9857711589c7436e557b412fe57d7ab4802ec/SQL/Move%20and%20time%20difference._script%205.sql)

These are the four foundational data tables used throughout the analysis. All the other 39 tables created are extracted and queried from these four tables.

Therefore, the report forward will focus on analyzing the following variables using SQL (SQLite DB browser), Python (Pandas, Matplotlib and Numpy libraries), several R packages and PowerBI for visualization:

Table 4: Important Variables Overview

| chess_games       | rapid        | chess_openings | play_time_count | 
|-------------------|--------------|----------------|-----------------|
| date              | date         | date           | date            |  
| opponentRating    | user_color   | Opening        | gameId          | 
| startTime         | result       | Move           | startTime       | 
| endTime           | rating (User rating)      | Color          | endTime         |
| -                 | move         | -              | time_difference_in_minutes  | 
| -                 | outcome      | -              | -              | 
| -                 | opening      | -              | -              | 
| -                 | opponent     | -              | -              | 
| **2405 rows**         | **2336 rows**    | **51 rows**        | **2336 rows**     |

Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql), [SQL script 5](https://github.com/LucasChaka/Chess_Analytics/blob/b9c9857711589c7436e557b412fe57d7ab4802ec/SQL/Move%20and%20time%20difference._script%205.sql) 

To conduct the visualization, the four data tables are imported from the database to PowerBI using [ODBC](https://learn.microsoft.com/en-us/sql/odbc/reference/what-is-odbc?view=sql-server-ver16). [ODBC](https://learn.microsoft.com/en-us/sql/odbc/reference/what-is-odbc?view=sql-server-ver16) is a library containing data access routines, which makes it easier to create a pipeline between SQLite and PowerBI. For further information on how to link ODBC with PowerBI, please refer to [docs.devart.com](https://docs.devart.com/odbc/sqlite/powerbi.htm).


## Analysis

### A general data overview: What can we learn about the data?

Initially, the first thing that comes to mind for any chess enthusiast is what is commonly and mistakenly referred to as the Elo score, a less modified version of the Glicko rating system. According to [Dr. Mark E. Glickman, The Glicko System](http://www.glicko.net/glicko/glicko.pdf), the Glicko system is a modified Elo rating system that assesses the strength of a player in zero-sum two-player games. (Please refer to the full mathematical function of the rating system on [Dr. Mark E. Glickman](http://www.glicko.net/glicko/glicko.pdf)). However, for the generality associated with calling the rating system "the Elo score", the report will refer to the rating system as the Elo rating going forward. It should be noted here that the rating score of [lichess.org](https://lichess.org) is different from the Elo rating of [chess.com](https://www.chess.com/).

Chess players, especially online chess players, practice to increase their Elo score over time. Elo scores can help a player assess their level, whether beginner, intermediate, master, or grandmaster. The following table depicts the hierarchy of Elo scores:

Table 5: Elo Rating Hierarchy

| Rating range       | Title                           |
|--------------------|---------------------------------|
| 2800+ Elo          | World Champion                  |
| 2700-2800 Elo      | World Championship contender    |
| 2600-2700 Elo      | Super Grandmaster               |
| 2500-2600 Elo      | Grandmaster                     |
| 2400-2500 Elo      | International Master            |
| 2200-2400 Elo      | Master                          |
| 2000-2200 Elo      | Expert                          |
| 1800-2000 Elo      | Class A - Strong club player    |
| 1600-1800 Elo      | Class B - Club team player      |
| 1400-1600 Elo      | Class C - Club player           |
| 1200-1400 Elo      | Class D - Hobby player          |
| 1000-1200 Elo      | Class E - Advanced beginner     |
| 750-1000 Elo       | Class F - Beginner/novice       |
| Below 750 Elo      | Complete beginner               |

Source: [www.hiarcs.com](https://www.hiarcs.com/hce-manual/pc/Eloratings.html), [chess.com/elo-rating-chess](https://www.chess.com/terms/elo-rating-chess)

The Elo score depicted over time shows the player's improvement over time. If an individual plays regularly, it is expected to see a positive trend over time. John's Elo is a very good example of such an improvement as depicted below.

Figure 1: John's daily aggregated Elo rating over time.

![Figure 1](https://github.com/LucasChaka/Chess_Analytics/assets/140816619/ff1a1087-0e6d-4950-8cac-f953abf03303)

Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql), [Chess Analytics Visuals](https://github.com/LucasChaka/Chess_Analytics/blob/850df4810b7da93186b8362fcc5907cb2f7e13c8/PowerBI/Chess%20Analytics%20Visuals.pbix)

John's Elo score dropped significantly from February 2023 to around the end of March 2023. The reason can be due to the overestimation John has regarding his own capabilities. When first registering on [chess.com](https://www.chess.com/), novice players can overestimate their skill as intermediate, hence the jump from the average daily maximum Elo score of 1,101.6 to 569.2. However, there is a volatile Elo variation until the trend starts to go up from around the beginning of July 2023, reaching the advanced beginner level and sticking in the 90th percentile. On average, John's Elo score is 739.91, with his median being less, a mere 696.25 Elo score. This depicts the Elo score distribution of John is skewed to the right over time. The following figure shows John's histogram against the density line.

Figure 2: John's Elo rating (User rating) distribution

![Figure 2](https://github.com/LucasChaka/Chess_Analytics/assets/140816619/b3dd3baf-8bdd-4345-851f-75a44b3c2e33)

Source: [Python_histogram](https://github.com/LucasChaka/Chess_Analytics/blob/42f1b89dd80f712c082999ee6686867f033d2945/Python/Python_histogram.ipynb), [Chess Analytics Visuals](https://github.com/LucasChaka/Chess_Analytics/blob/850df4810b7da93186b8362fcc5907cb2f7e13c8/PowerBI/Chess%20Analytics%20Visuals.pbix)

Additionally, John's overestimation of his capabilities can further be realized by the yellow dots on the following box plot. Almost all of the yellow dots are above approximately 1070. However, these outliers will be treated as true outliers as they show an aspect of John's behavior.

Figure 3: A boxplot visualization of Jon's Elo ratings

![Fig 3](https://github.com/LucasChaka/Chess_Analytics/assets/140816619/242d42c1-bb75-490d-8b30-1138c0108ae8)

Source: [Chess Analytics Visuals](https://github.com/LucasChaka/Chess_Analytics/blob/850df4810b7da93186b8362fcc5907cb2f7e13c8/PowerBI/Chess%20Analytics%20Visuals.pbix)







