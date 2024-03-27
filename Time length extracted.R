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

time_of_play <- dbGetQuery(con, "SELECT date, startTime, endTime FROM chess_games WHERE timeClass ='rapid'")

head(time_of_play)

# 
time_of_play$startTime <- as.POSIXct(time_of_play$startTime, format = "%H:%M:%S")
time_of_play$endTime <- as.POSIXct(time_of_play$endTime, format = "%H:%M:%S")

# Calculate time difference in minutes
time_of_play$time_difference_in_minutes <- round((difftime(time_of_play$endTime, time_of_play$startTime, units = "mins")),2)  


head(time_of_play)



# 
dbWriteTable(con, "play_time_count", time_of_play, overwrite = TRUE)

# 
dbDisconnect(con)

