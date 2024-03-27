# Load libraries
library(readr)
library(DBI)
library(RSQLite)

# 
setwd("C:/Users/lucas/Desktop/Data Science/Chessdotcom")
getwd()


# 
con <- dbConnect(RSQLite::SQLite(), dbname = "chess_analytics.db")

#

time_of_play <- dbGetQuery(con, "SELECT date, gameID, startTime, endTime FROM chess_games WHERE timeClass ='rapid'")

head(time_of_play)

# 
time_of_play$startTime <- as.POSIXct(time_of_play$startTime, format = "%H:%M:%S")
time_of_play$endTime <- as.POSIXct(time_of_play$endTime, format = "%H:%M:%S")

# Calculate time difference in minutes
time_of_play$time_difference_in_minutes <- round((difftime(time_of_play$endTime, time_of_play$startTime, units = "mins")),2)  


head(time_of_play)



# 
dbWriteTable(con, "play_time", time_of_play, overwrite = TRUE)

#In case there are games played around midnight, the result might be a minus which is not realistic.
#Using SQL in R for ease of usage.

negatives <- dbGetQuery(con, "SELECT c1.date, c2.gameID, c2.time_difference_in_minutes
                              FROM rapid AS c1 
                              INNER JOIN play_time AS c2	
	                            ON c1.ROWID=c2.ROWID
                              WHERE time_difference_in_minutes LIKE '-%';	")

head(negatives)

#There are negative time differences, which is not correct.
#Therefore,...

time_of_play$time_difference_in_minutes <- with(time_of_play, {
  ifelse(endTime < startTime,  # Check if endTime is before startTime
         difftime(endTime + 24 * 60 * 60, startTime, units = "mins"),  # If so, add 24 hours to endTime
         difftime(endTime, startTime, units = "mins"))  # Calculate time difference
})



time_of_play$startTime <- format(time_of_play$startTime, format = "%H:%M:%S")
time_of_play$endTime <- format(time_of_play$endTime, format = "%H:%M:%S")

time_of_play$time_difference_in_minutes<-round((time_of_play$time_difference_in_minutes), 2)

head(time_of_play)

dbWriteTable(con, "play_time_count", time_of_play, overwrite = TRUE)

dbDisconnect(con)
