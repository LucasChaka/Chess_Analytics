# Chess Data Analytics: Enhancing chess skills through data analysis(in progress)

## Introduction (to be edited in the end)

Many individuals who grasp the rules of chess but don't engage in it frequently believe that winning solely hinges on tactical maneuvering. However, chess encompasses far more than mere tactics. Opening theories, for example, can lead to swift victories, some unfolding in as few as three moves (such as the scholar's mate). The middle game, after players have strategically positioned their pieces, involves a plethora of tactics and strategies, ranging from basic skewers, forks, and pins to more intricate techniques like zugzwang. These maneuvers often dictate the outcome of the endgame, which may have been foreseen by both players, one, or neither.

A strong opening sets the stage for a robust middle game or endgame. Furthermore, the endgame itself relies heavily on the player's knowledge, focus, and other factors, whether acknowledged at the time or not. However, achieving a favorable endgame result often demands meticulous analysis of each game, aiming to enhance future performance. Such scrutiny involves a detailed review: identifying errors, evaluating effective moves, and preparing for subsequent matches. But what about a macro analysis, which offers a holistic review of all games played by one individual instead of one specific game? This comprehensive approach includes examining all advantageous openings used, common strategies among opponents of similar caliber, as well as the player's strengths, weaknesses, and noteworthy opponents.

While obtaining such data may pose a challenge, particularly with most games occurring without formal recording, recent years, especially post Netflix's limited series, "The Queen's Gambit", have witnessed a surge in chess's popularity, particularly online. Platforms like [chess.com](https://www.chess.com/) and [lichess.org](https://lichess.org) have seen significant subscription increases, resulting in detailed game recordings and insights. [chess.com](https://www.chess.com/) provides opportunities through a PGN format, while web applications such as [chessinsights.xyz](https://chessinsights.xyz/) offer raw data, streamlining analysis processes. This report aims to delve into a player's gameplay, offering macro and holistic perspectives for improvement.

However, individual player analyses have inherent limitations; for instance, the range of chess openings is constrained to the player under scrutiny. Yet, leveraging data from top chess masters can broaden the analytical scope. 

**DISCLAIMER:** For privacy reasons, the player's username remains undisclosed. Analysts interested in conducting similar macro analyses can obtain data from [chessinsights.xyz](https://chessinsights.xyz/). Throughout this report, the player is referenced by the pseudonym *John*."

## Methodology
                      3.	Methodology
                      •	Describe the methods and techniques used for data collection and analysis.
                      •	Explain any assumptions made and limitations encountered during the analysis.
### Data Collection

The data utilized in this analysis primarily originates from [chessinsights.xyz](https://chessinsights.xyz/), a web application designed for chess enthusiasts and data scientists. Users can input a specific username registered on [chess.com](https://www.chess.com/) to access a comprehensive list of raw data alongside a limited set of visualizations tailored for analytical purposes. These data sets encapsulate a history of live chess games played across different geographical regions or among friends, providing valuable insights into players' performance. It's worth noting that alternative platforms such as [lichess.org](https://lichess.org) also offer similar data accessibility.

Initially, two sets of data were downloaded in CSV format: the raw data and a relatively cleaner version, which in the following report will be refered to as the *explorable data*. While the raw data offers a wealth of information and variables, its presentation can be somewhat messy. Conversely, the cleaner dataset, though less extensive, is more organized and easier to navigate. However, it's essential to recognize that certain variables available in the cleaner dataset may not be present in the raw data. Thus, to ensure comprehensive analysis, it's advisable to leverage both datasets in tandem.

The data exported to a CSV file from [chessinsights.xyz](https://chessinsights.xyz/) encompasses various columns (referred to as such for now, as the data is raw and has not yet undergone any ETL processes).

Table 1: Summary of Chess Game Data: Raw and Explorable Data Comparison

| Raw Data Column   | Explorable Data Column | Description                                                                                                         |
|--------------------|------------------------|---------------------------------------------------------------------------------------------------------------------|
| userAccuracy       | Accuracy               | Indicates the player's accuracy, reflecting how closely they adhered to optimal moves as determined by the [chess.com](https://www.chess.com/) engine. |
| opponentAccuracy   | -                      | Reflects the opponent's accuracy, measuring their adherence to optimal moves as determined by the [chess.com](https://www.chess.com/) engine.           |
| gameURL            | GameUrl                | Direct link to the specific game played.                                                                           |
| gameID             | -                      | Unique identifier for the game.                                                                                     |
| timeClass          | TimeClass              | Specifies the game type: rapid (10-minute and above), blitz (3-minutes), or bullet (1-minute).                                |
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


### Data Preprocessing 

Once the initial two datasets are imported locally, as is common with most data, they undergo preprocessing. These datasets are then imported into R-studio to create an SQL database. Please refer to the R code in the GitHub file [Chess Database Setup.R](https://github.com/LucasChaka/Chess_Analytics/blob/cd813ace82649e8cf67aca36db64211f8ca67b58/R/Chess%20Database%20Setup.R). Once the database is created, it is stored in a light SQL version, SQLite, along with its DB Browser.

SQL code 1: The two data sets

                    --Data set 1
                    SELECT *
                    FROM chess_games; 
                    
                    --Data set 2
                    SELECT *
                    FROM explorable_data;

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

Source: [SQL script 1](https://github.com/LucasChaka/Chess_Analytics/blob/048927b76de71e8c17a3cda6af770641c0271b5c/SQL/Chess%20game%20statistics_script%201.sql)

The columns included in the raw data but not in the explorable data, namely *opponentRating*, *startTime*, and *endTime*, are deemed necessary. However, there is no immediate need to join these columns, as they can be extracted when required at a later point. The memory capacity of the local machine to accommodate one more data table is not an issue. Therefore, the report will focus on analyzing the following variables:

Table 1: Summary of Chess Game Data: Raw and Explorable Data Comparison

| chess_games   | rapid | chess_openings                                                                                                         |
|--------------------|------------------------|---------------------------------------------------------------------------------------------------------------------|
|    -                | date                 | Date of the game played.                                             |
| -              | user_color               | Opponent's user ID/name.                                                                                                |
| -         | result                      | Win, lose or draw.                                                                                                 |
| -           | rating                     | Player's rating.                                                                                       |
| -                | Result                 | Outcome of the game: win, loss, or draw.                                                                            |
| -                  | move                  | The amount of move the game took.                                                                                           |
| -           | outcome                     | Specific game outcome, e.g., checkmate, abandonment, resignation, or draw.                                 |
| -               | opening                | Type of theoritical opening employed in the game.                                                                           
| -                | opponent                |                                           |



 

Sources: The data used in this analysis was collected from [specify sources, e.g., Chess.com API, internal databases].
Scope: The dataset comprises [describe the scope of the data, e.g., chess game records] spanning from [start date] to [end date].
Variables: The main variables included in the dataset are [list key variables, e.g., game outcome, opening moves, player ratings].
Preprocessing: Before analysis, the data underwent preprocessing steps to [describe any data cleaning, transformation, or normalization procedures].
Analysis Techniques:
Descriptive Analysis: Initial exploration of the dataset involved descriptive statistics to summarize the characteristics and distributions of the variables.
Exploratory Data Analysis (EDA): EDA techniques, such as data visualization and summary statistics, were employed to identify patterns, trends, and outliers in the data.
Statistical Analysis: Various statistical tests, including [specify tests, e.g., t-tests, chi-square tests], were conducted to investigate relationships between variables and test hypotheses.
Machine Learning Models: Machine learning algorithms, such as [specify algorithms, e.g., logistic regression, decision trees], were utilized for predictive modeling or classification tasks.
Software and Tools:
Programming Languages: The analysis was performed using [specify programming languages, e.g., R, Python] for data manipulation, analysis, and visualization.
Statistical Packages: Statistical packages such as [specify packages, e.g., pandas, scikit-learn] were utilized for conducting statistical analyses and building machine learning models.
Visualization Tools: Visualization tools such as [specify tools, e.g., Matplotlib, ggplot2] were employed to create visualizations for interpreting and presenting the results.
Assumptions and Limitations:
Assumptions: Certain assumptions were made during the analysis, including [list any assumptions, e.g., normality of data distribution, independence of observations].
Limitations: The analysis is subject to certain limitations, such as [describe any limitations, e.g., data quality issues, sample size constraints], which may impact the generalizability of the findings.
Ethical Considerations:
Data Privacy: Measures were taken to ensure data privacy and confidentiality, adhering to [specify relevant data privacy regulations, e.g., GDPR, HIPAA].
Bias and Fairness: Efforts were made to mitigate bias and ensure fairness in the analysis, including [describe steps taken, e.g., algorithmic fairness checks, bias detection methods].
Validation and Verification:
Validation: The results of the analysis were validated through [describe validation procedures, e.g., cross-validation, sensitivity analysis] to assess the robustness and reliability of the findings.
Verification: The analysis process was verified through [specify verification methods, e.g., peer review, code review] to ensure accuracy and reproducibility.
This methodology outlines the approach and procedures followed in conducting the analysis, providing transparency and clarity to the reader.













