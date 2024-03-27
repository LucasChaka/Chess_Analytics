
rm(list=ls())

#connect to my database

con <- dbConnect(RSQLite::SQLite(), dbname = "chess_analytics.db")

# distribution table
distribution <- dbGetQuery(con, "SELECT * FROM opponent_vs_user_distribution;")
head(distribution)


library(dplyr)


#I used here the 1.5 outlier rule
#quartiles and IQR
quartiles_user <- quantile(distribution$average_user_rating, probs = c(0.25, 0.75))
Q1_user <- quartiles_user[1]
Q3_user <- quartiles_user[2]
IQR_user <- Q3_user - Q1_user



#Q3 + (IQR * 1.5)
Q3_plus_IQR_times_user <- Q3_user + (IQR_user * 1.5)

#Q1 - (IQR * 1.5)
Q1_minus_IQR_times_user <- Q1_user - (IQR_user * 1.5)

#####


quartiles_opponent <- quantile(distribution$average_opponent_rating, probs = c(0.25, 0.75))
Q1_opponent <- quartiles_opponent[1]
Q3_opponent <- quartiles_opponent[2]
IQR_opponent <- Q3_opponent - Q1_opponent



#Q3 + (IQR * 1.5)
Q3_plus_IQR_times_opponent <- Q3_opponent + (IQR_opponent * 1.5)

#Q1 - (IQR * 1.5)
Q1_minus_IQR_times_opponent <- Q1_opponent - (IQR_opponent * 1.5)




box_plot_user <- data.frame(
  "variables" = c("Q1", "Q3", "IQR", "Q1_minus_IQR_times_1.5", "Q3_plus_IQR_times_1.5"),
  "user_quantiles" = c(Q1_user, Q3_user, IQR_user, Q1_minus_IQR_times_user, Q3_plus_IQR_times_user))

head(box_plot_user)


box_plot_opponent <- data.frame(
  "variables" = c("Q1", "Q3", "IQR", "Q1_minus_IQR_times_1.5", "Q3_plus_IQR_times_1.5"),
  "opponent_quantiles" = c(Q1_opponent, Q3_opponent, IQR_opponent, Q1_minus_IQR_times_opponent, Q3_plus_IQR_times_opponent))

head(box_plot_opponent)



box_plot<-merge(box_plot_user, box_plot_opponent, by="variables")
head(box_plot)


dbWriteTable(con, "box_plot", box_plot, overwrite = TRUE)


dbDisconnect(con)











