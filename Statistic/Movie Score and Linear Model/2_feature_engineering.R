# Feature Engineering
#############################################################################
# Award
#############################################################################
# Adding total award feature
# c1 <- ifelse(movies$best_pic_nom == "yes", as.integer(1), as.integer(0))
# c2 <- ifelse(movies$best_pic_win == "yes", as.integer(1), as.integer(0))
# c3 <- ifelse(movies$best_actor_win == "yes", as.integer(1), as.integer(0))
# c4 <- ifelse(movies$best_actress_win == "yes", as.integer(1), as.integer(0))
# c5 <- ifelse(movies$best_dir_win == "yes", as.integer(1), as.integer(0))
# award <- data.frame(c1, c2, c3, c4, c5)
# movies$award <- rowSums(award)

#############################################################################
# Date
#############################################################################
# Finding the days length untill the dvd release
movies$date_dff <- as.integer(difftime(movies$dvd_date, movies$thtr_date, units = "days"))
movies$thtr_date <- NULL
movies$dvd_date <- NULL

# Since we do have negative number, which does not make sense, i will mark them as 0, may be international movie
movies$date_dff[movies$date_dff < 0] = 0

#############################################################################
# Make popularity feature
#############################################################################
movies$popularity <- ifelse(movies$imdb_num_votes >= 58300, 'high', 
                            ifelse(movies$imdb_num_votes <= 4546, 'low', 'mid'))
movies$popularity <- as.factor(movies$popularity)
levels(movies$popularity) <- c("low", "mid", "high")
#############################################################################
# Finding avg date differneces based on each factor veriables
#############################################################################
mu_all <- aggregate(date_dff ~  genre + mpaa_rating + critics_rating + audience_rating + 
                         best_pic_nom + best_pic_win +  best_actor_win + best_actress_win + best_dir_win + 
                         top200_box + popularity, movies, mean, na.rm = TRUE)

colnames(mu_all)[12] <- "mu_all"
movies <- merge(movies, mu_all, by = c("genre", "mpaa_rating", "critics_rating", "audience_rating", 
                                       "best_pic_nom", "best_pic_win", "best_actor_win", "best_actress_win", 
                                       "best_dir_win", "top200_box", "popularity"), all.x = TRUE)

saveRDS(movies, "./movies01.rds")
