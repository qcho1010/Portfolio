library(dplyr)
library(tidyr)
setwd("C:/Users/Kyu/Documents/specialization/18-Unlock Value in Massive Datasets (University of California)/6-Capstone Project/big_data_capstone_datasets_and_scripts/flamingo-data")
ad <- read.csv("ad-clicks.csv")
buy <- read.csv("buy-clicks.csv")
game <- read.csv("game-clicks.csv")
level <- read.csv("level-events.csv")
team <- read.csv("team.csv")
teamAssign <- read.csv("team-assignments.csv")
user <- read.csv("users.csv", stringsAsFactors=FALSE)
userSess <- read.csv("user-session.csv")

# top 3 userID those click the ad the most
adDf <- tally(group_by(ad , userId))
head(addf[order(-adDf$n),], 3)

# top 3 popular ad categories
adDf2 <- tally(group_by(ad , adCategory))
head(adDf2[order(-adDf2$n),], 3)

# top 3 money spent teams 
buy %>% 
    group_by(team) %>%
    summarise(total = sum(price)) %>%
    top_n(3, total)

buy %>% 
    group_by(userId) %>%
    summarise(total = sum(price)) %>%
    top_n(3, total)

# top 3 user who hits the most and their team level
gameDf <-tally(group_by(game[game$isHit == 1,], userId))
head(gameDf[order(-gameDf$n),], 3)
gameTopUserid <- as.list(gameDf[order(-gameDf$n),][1:3, 'userId'])
head(game[game$userId == gameTopUserid[[c(1,1)]],], 1)
head(game[game$userId == gameTopUserid[[c(1,2)]],], 1)
head(game[game$userId == gameTopUserid[[c(1,3)]],], 1)

# top 3 team that sum of teammate hits the most and their team level
gameDf2 <-tally(group_by(game[game$isHit == 1,], teamId))
head(gameDf2[order(-gameDf2$n),], 3)
gameTopTeamid <- as.list(gameDf2[order(-gameDf2$n),][1:3, 'teamId'])
head(game[game$userId == gameTopTeamid[[c(1,1)]],], 1)
head(game[game$userId == gameTopTeamid[[c(1,2)]],], 1)
head(game[game$userId == gameTopTeamid[[c(1,3)]],], 1)

gameDf3 <- tally(group_by(game, teamId))
gameDf3[gameDf3$teamId == gameTopTeamid[[c(1,1)]], ]
gameDf3[gameDf3$teamId == gameTopTeamid[[c(1,2)]], ]
gameDf3[gameDf3$teamId == gameTopTeamid[[c(1,3)]], ]

head(gameDf3[order(-gameDf3$n), ], 3)


# higest hit ratio team = total hit / total try
game %>%
    group_by(teamId) %>%
    summarise(hitRatio = mean(isHit)) %>%
    top_n(3, hitRatio)


# average team level for each eventType
levelDf <- level %>%
    group_by(eventType) %>%
    summarise(avgLevel = mean(teamLevel))

# top 3 highest strength teams
head(team[order(-team$strength), c('teamId', 'strength')], 3)

# average age player
library(lubridate) 
user$dob = as.Date(user$dob)
user$dob = year(user$dob)
2016 - mean(as.integer(user$dob))

# average team level for each platformType
userSessDf <- userSess %>%
    group_by(platformType) %>%
    summarise(avgLevel = mean(teamLevel)) %>%
    top_n(3, avgLevel)


# hit ratio of each player
buyDf <- buy %>%
    group_by(userId) %>%
    summarise(totalSpent = sum(price)) %>%
    top_n(3, totalSpent)
buyId <- buyDf[order(-buyDf$totalSpent), ]$userId
gameDf <- with(game, game[userId %in% buyId, ])

gameDf <- gameDf %>%
    group_by(userId) %>%
    summarise(hitRatio = mean(isHit)) %>%
    top_n(3, hitRatio)
gameDf <- gameDf[order(-gameDf2$hitRatio), ]
gameDf
gameId <- gameDf$userId
userSessDf <- with(userSess, userSess[userId %in% gameId, ])
table(userSessDf$userId, userSessDf$platformType)

############
# Plotting
############
library(ggplot2)
# plot 1
buyDf <- tally(group_by(buy, buyId))
buyDf <- buyDf[order(-buyDf$n), ]

g <- ggplot(buyDf, aes(reorder(as.factor(buyId), n), y=n)) + 
    geom_bar(stat="identity") + 
    coord_flip() +
    xlab("Item ID") +
    ylab("Total Purchase Count") 
g
ggsave('plot1.png', g)

# plot2
buyDf2 <- buy %>%
    group_by(buyId) %>%
    summarise(total = sum(price))
buyDf2 <- buyDf2[order(-buyDf2$total), ]

g <- ggplot(buyDf2, aes(reorder(as.factor(buyId), total), y=total)) + 
    geom_bar(stat="identity") + 
    coord_flip() +
    xlab("Item ID") + 
    ylab("Total Amount Made")
g
ggsave('plot2.png', g)

# plot3
buyDf3 <- buy %>%
    group_by(userId) %>%
    summarise(total = sum(price)) %>%
    top_n(10, total)

buyDf3 <- buyDf3[order(-buyDf3$total), ]
g <- ggplot(buyDf3, aes(reorder(as.factor(userId), total), y = total)) +
    geom_bar(stat="identity") +
    coord_flip() +
    xlab("User ID") +
    ylab("Total Amount Spent")
g
ggsave('plot3.png', g)
