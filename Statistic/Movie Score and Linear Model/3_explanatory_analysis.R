# Research quesion 1:  
ggplot(movies, aes(critics_rating, audience_score)) + 
     geom_boxplot(aes(colour=popularity)) +
     labs(title = "Audience Score vs. Critics Rating") +
     xlab("Critics Rating") +
     ylab("Audience Score")

movies %>%
     group_by(critics_rating) %>%
     summarise(mean(audience_score))

ggplot(movies, aes(audience_rating, audience_score)) + 
     geom_boxplot(aes(colour=popularity))

movies %>%
     group_by(audience_rating) %>%
     summarise(mean(audience_score))


ggplot(movies, aes(mu_all, audience_score)) + 
     geom_boxplot(aes(group=genre, color=genre), size=1) +
     facet_wrap(~genre, nrow = 2) +
     geom_smooth(method = "lm")

ggplot(movies, aes(imdb_rating, audience_score)) +
     geom_point() +
     facet_wrap(~top200_box, nrow = 2) + 
     geom_smooth(method = "lm")


ggplot(movies, aes(imdb_rating, fill = popularity, colour = popularity)) +
     geom_density(alpha = .1) + 
     xlab("imdb_rating")

ggplot(movies, aes(imdb_num_votes, audience_score)) +
     geom_point(aes(colour = award), size = 2) +
     geom_smooth(method = "lm")

ggplot(movies, aes(mu_all, audience_score)) + 
     geom_point(aes(group=popularity, color=popularity), size=2)

###############################################################
# Build base model
###############################################################
mdl_lm6 <- lm(audience_score ~ . -best_pic_nom -best_pic_win -best_actor_win 
              -best_actress_win -best_dir_win -mpaa_rating -top200_box -critics_score -popularity, movies)
sum_lm6 <- summary(mdl_lm6)
sum_lm6$adj.r.squared

remove <- names(movies) %in% c("best_pic_nom", "best_pic_win", "best_actor_win", "best_actress_win", "best_dir_win", "mpaa_rating", "top200_box", 
                               "critics_score", "popularity")
movies <- movies[!remove]
saveRDS(movies, "./movies02.rds")
