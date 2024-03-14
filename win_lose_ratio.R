

rm(list=ls())

#connect to my database

con <- dbConnect(RSQLite::SQLite(), dbname = "chess_analytics.db")

# win/loss ratio table
win_loss_ratio_white <- dbGetQuery(con, "SELECT * FROM win_lose_ratio_white_opening ORDER BY 1;")
head(win_loss_ratio_white)

win_loss_ratio_black <- dbGetQuery(con, "SELECT * FROM win_lose_ratio_black_opening ORDER BY 1;")
head(win_loss_ratio_black)


# opening frequency table
opening_frequency_black <- dbGetQuery(con, "SELECT * FROM opening_frequency_black ORDER BY 1;")
head(opening_frequency_black)

opening_frequency_white <- dbGetQuery(con, "SELECT * FROM opening_frequency_white ORDER BY 1;")
head(opening_frequency_white)

#calculate the adjusted win_loss_ratio---white

win_loss_ratio_white$log_white<-log(win_loss_ratio_white$win_lose_ratio)
win_loss_ratio_white$frequency<-opening_frequency_white$amount_of_times_opening_was_used




win_loss_ratio_white$adjusted_win_los_ratio<-win_loss_ratio_white$log_white*win_loss_ratio_white$frequency

head(win_loss_ratio_white)

#calculate the adjusted win_loss_ratio---black


win_loss_ratio_black$log_black<-log(win_loss_ratio_black$win_lose_ratio)
win_loss_ratio_black$frequency<-opening_frequency_black$amount_of_times_opening_was_used


win_loss_ratio_black$adjusted_win_los_ratio<-win_loss_ratio_black$log_black*win_loss_ratio_black$frequency

head(win_loss_ratio_black)



#export the new created tables to the chess_analytics database

dbWriteTable(con, "w_l_ratio_black", win_loss_ratio_black, overwrite = TRUE)
dbWriteTable(con, "w_l_ratio_white", win_loss_ratio_white, overwrite = TRUE)


dbDisconnect(con)