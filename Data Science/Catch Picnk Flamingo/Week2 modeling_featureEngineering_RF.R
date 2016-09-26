library(dplyr)
library(tidyr)
setwd("C:/Users/Kyu/Documents/specialization/18-Unlock Value in Massive Datasets (University of California)/6-Capstone Project/big_data_capstone_datasets_and_scripts/combined-data")
comb <- read.csv("combined-data.csv", na.strings=c("NULL"))


############################################################
# Exploration
############################################################
str(comb)
nrow(comb)
nrow(comb[!is.na(comb$count_buyId), ])
comb$f

############################################################
# Feature Engineering
############################################################
# buyerType
comb$avg_price <- as.numeric(comb$avg_price)
comb[is.na(comb$avg_price), 'avg_price'] <- 0
comb$buyerType <- ifelse(comb$avg_price > 5, 'HighRollers', 'PennyPinchers')

write.csv(comb, 'new-combined-data.csv')
comb <- read.csv("new-combined-data.csv", na.strings=c("NULL"))

# hitRatio
comb$hitRatio <- (comb$count_hits)/(comb$count_gameclicks)
comb[is.infinite(comb$hitRatio), 'hitRatio'] <- 0
comb[comb$count_gameclicks < 10, 'hitRatio'] <- 0
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
comb$hitRatio <- range01(comb$hitRatio)

# realLevel
comb$realLevel <- (comb$teamLevel)*(comb$hitRatio)

# traffic
comb$userSessionId2 <- round(comb$userSessionId/1000, 1)
df <- as.data.frame(tally(group_by(comb, userSessionId2)))
comb <- comb %>%
    left_join(df, comb, by="userSessionId2")
comb$userSessionId2 <- NULL

comb$traffic <- as.factor(ifelse(comb$n > mean(comb$n), 'busy', 'slow'))

# cleaning
comb$X <- NULL; comb$userSessionId <- NULL; comb$count_buyId <- NULL ; comb$avg_price <- NULL
colnames(comb)[9] <- "sessionTraffic"

# saving
write.csv(comb, 'new-combined-data.csv')
