# Chess Analytics 1.0: Data Analytics to Enhance Chess Skills

## Introduction (to be edited in the end)

As a passionate chess lover and data enthusiast, I set out on an exciting mission: to use the power of data analytics to boost my game. Fueled by my desire for more wins, I dove into my gaming history, searching for patterns and insights that could give me an edge. Now, join me as I unveil the results of my analysis, revealing how data-driven strategies can transform chess play into victory. In this analysis, I delve into the fascinating world of chess through the lens of data analytics. My goal? To uncover hidden patterns and strategic insights within my live gameplay history that could elevate my performance on the board. With a keen eye for detail and a thirst for victory, I explore the depths of my gaming data to unlock secrets that can sharpen my tactical acumen and lead to more triumphs. 

Exploring open data is like diving into a treasure trove, and chess.com offers a myriad of options to tap into that wealth. One avenue is downloading data from your archives in a PGN format. Yet, amidst the sea of information, navigating through the clutter can be a challenge. Enter [chessinsights.xyz](https://chessinsights.xyz/), a beacon of simplicity and utility in the vast ocean of chess data. Crafted by a fellow chess enthusiast, whom I am not affiliated with yet respect for the skills he put into such a web application, this website not only streamlines the analysis process but also provides access to raw data for further exploration. It's a testament to the power of community-driven tools, making complex analysis a breeze.

Therefore, leveraging PostgreSQL, R, and Python, I've curated the insights presented in this report, delving into the intricacies of my chess journey. My aim is to decipher the factors influencing my win rate and unearth actionable insights to refine my future gameplay strategies. Through meticulous analysis and a data-driven approach, I endeavor to enhance my understanding of the game dynamics and pave the path toward continued improvement.

## Table of Contents

## All about the data

The data needed is a history of live chess game plays played through two players from different parts of the world or among friends. The data is only fetched from live [chess.com](https://www.chess.com/) games. However, there are also other platforms such as [lichess.org](https://lichess.org), where one can get data on one's own game play.
Two data were initially downloaded in a csv format from [chessinsights.xyz](https://chessinsights.xyz/), a raw data and a relatively cleaner raw data. The differences between the two are, the raw data conains so much more redundant information than the explorable data yet at the same time has no information loaded in some of the most important columns for analysis. For example, the column *result* doesn't show the win, loss or draw but shows the outcome of the game without specifying who checkmated who, who resigned and so on. That is something, that should be extracted by treating the two data as relational data. 
The data exported to a csv file from [chessinsights.xyz](https://chessinsights.xyz/) contains the following columns (I call it columns for now as its a raw data have not yet went through ETL processes.):

Table 1: A Summarization of Chess Game Data 

| Raw Data Column     | Explorable Data Column | Explanation                                                                                                                 |
|----------------------|------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| userAccuracy         | Accuracy                | Accuracy of the player, representing how closely they played to the best possible moves as determined by the engine.       |
| opponentAccuracy     | -                        | Accuracy of the opponent, representing how closely they played to the best possible moves as determined by the engine.     |
| gameURL              | GameUrl                 | Reference to the specific game played.                                                                                     |
| gameID               | -                      | Reference to the game ID.                                                                                                   |
| timeClass            | TimeClass               | The type of game, whether it's rapid (a 10-minute long game), blitz (a 3-minute long game), or bullet (a 1-minute long game). |
| fen                  | -                      | A serial key of each game played.                                                                                          |
| userColor            | Color                   | The color the player played, either white or black.                                                                        |
| userRating           | Rating                  | The chess performance rating of the player.                                                                                |
| opponent             | Opponent                | The opponent's userID.                                                                                                     |
| opponentRating       | -                      | The opponent's ratings.                                                                                                    |
| opponentUrl          | -                      | Gives the link to the opponent's page.                                                                                     |
| result               | Result                  | The outcome of the game: win, loss, or draw.                                                                               |
| date                 | Date                    | Date of the game played.                                                                                                   |
| openingURL           | -                      | The URL that shows the theoretical opening moves.                                                                          |
| opening              | Opening                 | The type of opening used in the game.                                                                                      |
| startTime            | -                      | When the live game started.                                                                                                |
| endTime              | -                      | When the live game ended.                                                                                                  |
| pgn                  | Moves                   | All the moves of the particular game played.                                                                               |
| moveCount            | -                      | How many moves the whole game took.                                                                                        |
| outcome              | Outcome                 | The specific outcome of the game, such as checkmate, abandonment, resignation, or draw.                                    |

Source: [chessinsights.xyz](https://chessinsights.xyz/), [chess.com/ratings](https://www.chess.com/terms/chess-ratings#:~:text=The%20Glicko%20system%E2%80%94used%20on,when%20calculating%20each%20player's%20rating.), [chess.com/accuracy_blog](https://support.chess.com/article/1135-what-is-accuracy-in-analysis-how-is-it-measured#:~:text=Your%20Accuracy%20is%20a%20measurement,as%20determined%20by%20the%20engine.) 

However the raw data is just a complete mess, that I needed to transform. Once the data is imported to my local file. It should be important to create a database in SQL. Best way I found to do that is through R-studio. The argument is simple, it's much easier to create the [database in R](**R code for creating the database linke here), export it and when I need to do quantitative analysis, I could just import the database and extract the table that I need for further analysis. Although, it is also possible to do so in Python.

### A basic data exploration

Both the raw data and the explorable data have the same number of rows. Theere are no missing values of the important columns that are needed for analysis. However, columns like *accuracy*, *userAccuracy*, or *opponentAccuracy* have missing values. The reason for the missing value is due to two reasons
          - the payment subscription needed to show those measurements. Meaning that I have do not have premium subscription to [chess.com](https://www.chess.com/), then I can't access how my accuracy measures against my opponent
          - the second reason is that the player didn't use a one-time a day game review offered by [chess.com](https://www.chess.com/) after the games have been played.
The other column is *Won BY*, in the raw data, which is empty due to the mess of the raw data. However, this column is compensated by the *Result* column in the explorable data.
Three type of chess games were played by the player, blitz, rapid and bullet. 

There are several type of live game plays.
-  Bullet = Games under 3 minutes.
-  Blitz = Games over 3 minutes but under 10 minutes.
-  Rapid = Games 10 minutes
According to [live.chess](https://support.chess.com/article/330-why-are-there-different-ratings-in-live-chess#:~:text=Live%20Chess%20has%20three%20different,games%2010%20minutes%20and%20longer.), there are different types of skills involved, whether the game is long or short. Short games tend to be about fast thinking and wit while long games tend to be more tactical plays, with a meticulous attention to opening games, middle games and end games. There are also other variations of these three types of games, as listed on, [live.chess](https://support.chess.com/article/330-why-are-there-different-ratings-in-live-chess#:~:text=Live%20Chess%20has%20three%20different,games%2010%20minutes%20and%20longer.).

Between the dates of June 27th, 2018 and March 2nd, 2024, I have played 2405 live games in total. Among the out of the 2405 total games, 64 games were dedicated to blitz games, 2336 were dedicated to rapid games and 5 to bullets. 97.13 % of all live games were 10 minutes. 

Table 2: Summary of Live Chess Game Types Played

| game_amount | game_type | percentage |
|-------------|-----------|------------|
| 64          | blitz     | 2.66 %     |
| 5           | bullet    | 0.21 %     |
| 2336        | rapid     | 97.13 %    |

Source: [SQL code page]

Therefore, it would be easier to focus on the rapid games, for a more understanding of my own game play. 

## Detailed data exploration

To explore the data thoroghly, without complicated analysis. I ask the following questions; What were my Elo ratings as both white and black, and the total summary statistics?

- What were the average daily ratings as white, black, and the overall average rating of each day?
- What was the overall average rating for both me and my opponents?
- Did I play more games as white or black? If so, by what ratio?
- Does winning affect the likelihood of playing with certain pieces?
- Do I lose more games as white or black?
- What opening strategies led to the most wins?
- How have my opening strategies evolved over time?
- What is the win/loss ratio for each opening strategy?
- Who were the weakest and toughest opponents I faced?
- How many times did I win or lose against each opponent?
- How many times did I play against each opponent?
- How many moves did it take to win each game, and what was the duration of each game?




Methodology
3.1 Tools and Technologies
3.2 Analytical Approach

Analysis
4.1 Overview of Chess Gameplay
4.2 Performance Metrics
4.3 Opponent Analysis

Results and Insights
5.1 Patterns and Trends
5.2 Strategic Insights
5.3 Win Rate Analysis

Discussion
6.1 Implications
6.2 Limitations
6.3 Future Directions

Conclusion
7.1 Summary of Findings
7.2 Recommendations

References

Appendices


Provide a brief overview of the purpose and scope of your analysis.
Introduce the dataset and any relevant background information.
Data Overview
Briefly describe the dataset used for analysis.
Mention any preprocessing steps performed, such as cleaning or filtering.
Analysis Methodology
Outline the analytical approach used in your analysis.
Mention the queries executed to explore different aspects of the data.
Key Findings


Highlight any trends, patterns, or correlations discovered.
Results
Present the results of each analysis query in a clear and structured format.
Use tables, charts, or visualizations to illustrate key findings.
Provide interpretations and insights derived from the results.
Discussion
Discuss the implications of your findings in relation to your initial objectives.
Address any limitations or constraints encountered during the analysis.
Suggest potential areas for further investigation or improvement.
Conclusion
Summarize the main findings and insights gained from the analysis.
Reinforce the significance of your findings and their relevance to the overall objective.
Recommendations
Provide actionable recommendations based on your analysis.
Propose strategies or initiatives for improving chess skills based on the insights obtained.
Acknowledgments
Acknowledge any individuals, organizations, or sources that contributed to your analysis.
References
Include citations or references to any external sources or datasets used in your analysis.
Appendices
Optionally, include additional details or supplementary information, such as raw data or code snippets.
Format and Style
Maintain a professional tone and language throughout the report.
Use clear headings, subheadings, and bullet points for easy readability.
Ensure consistency in formatting and style, adhering to corporate standards.
Include relevant visuals, but avoid cluttering the report with excessive graphics.

Data Sources
Bibliography
