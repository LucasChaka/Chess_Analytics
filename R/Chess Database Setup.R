#####

rm(list=ls())

setwd("C:/Users/lucas/Desktop/Data Science/Chessdotcom")
getwd()

library(readr)

#Downloaded games
chess_games<-read.csv("Dinddong_all_2403021814.csv")#raw data
explorable_data<-read.csv("Dinddong_dataExport.csv")#explorable data

#chess openings data compiled from the web initially on excel
chess_openings<-read.csv("chess_openings.csv")

#Create my SQL database

install.packages("DBI")
install.packages("RSQLite")

library(DBI)
library(RSQLite)


chess_sql <- dbConnect(SQLite(), "chess_analytics.db")

dbWriteTable(chess_sql, "chess_games", chess_games)
dbWriteTable(chess_sql, "explorable_data", explorable_data)
dbWriteTable(chess_sql, "chess_openings", chess_openings)


dbDisconnect(chess_sql)

