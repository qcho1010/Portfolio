library(ggplot2)
library(dplyr)
library(statsr)
library(caret)

setwd("F:/specialization/22-Master Statistics with R (Duke University)/data")
load("eaca_movies.RData")

# Preprocessing
str(movies)
summary(movies)
movies <- transform(movies, studio = factor(movies$studio, exclude = NULL))
movies <- movies[, !(names(movies) %in% c("title", "title_type", "studio", "imdb_url", "rt_url",  "director", "actor1", "actor2", "actor3", "actor4", "actor5"))]

# Imputation
missing <- c("runtime", "studio", "dvd_rel_year", "dvd_rel_month", "dvd_rel_day")
movies$runtime[is.na(movies$runtime)] <- median(movies$runtime, na.rm=T)
movies$dvd_rel_year[is.na(movies$dvd_rel_year)] <- median(movies$dvd_rel_year, na.rm=T)
movies$dvd_rel_month[is.na(movies$dvd_rel_month)] <- median(movies$dvd_rel_month, na.rm=T)
movies$dvd_rel_day[is.na(movies$dvd_rel_day)] <- median(movies$dvd_rel_day, na.rm=T)

# Cleaning Date formmat
movies$thtr_date <- paste0(movies$thtr_rel_month,"/",movies$thtr_rel_day,"/",movies$thtr_rel_year) 
movies$dvd_date <- paste0(movies$dvd_rel_month,"/",movies$dvd_rel_day,"/",movies$dvd_rel_year) 

movies$thtr_date <- as.Date(movies$thtr_date, "%m/%d/%Y")
movies$dvd_date <- as.Date(movies$dvd_date, "%m/%d/%Y")

movies$thtr_rel_day <- NULL
movies$dvd_rel_year <- NULL
movies$dvd_rel_month <- NULL
movies$dvd_rel_day <- NULL
