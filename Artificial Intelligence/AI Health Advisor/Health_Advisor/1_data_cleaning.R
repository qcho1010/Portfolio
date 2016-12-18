library(sn)
library(caret)
setwd("~/Documents/archHack")

# init. data
size <- 10000
family_hist <- append(rep(0,size*.8), rep(1,size*.2)) # (no=0, yes=1)
male <- append(rep(1,5000), rep(0,5000)) # (no=0, yes=1)
age <- as.numeric(rsn(size, 35, 13, 10)) # size, mu, sd, skewness(-100, 100)
cigarette <- as.numeric(rsn(size, 1.2, 4, 10))
exercise <- as.numeric(rsn(size, 2, .7, 10))
stress <- as.numeric(rsn(size, 40, 15, 4))
grain <- as.numeric(rsn(size, 755, 230, 1))
vegetable <- as.numeric(rsn(size, 455, 150, 1))
meat <- as.numeric(rsn(size, 0.21, 0.2, 40))
calories <- as.numeric(rsn(size, 2640, 700, 1))
alcohol <- as.numeric(rsn(size, 7, 2, 10))
sugar <- as.numeric(rsn(size, 14, 4, 1))
cholesterol <- as.numeric(rsn(size, 200, 70, 1))
blood_press <- as.numeric(rsn(size, 120, 40, 1))
sodium <- as.numeric(rsn(size, 1500, 500, 1))

# init weight
cacn_w <- c(20, 10, 13, 60, -90, 50, -30, -45, 20, 30, 40, 30)
heart_w <- c(30, 12, 13, 20, -100, 70, -90, -85, 40, 40, 70, 10, 60, 60, 60s)

# combind data
canc_data <- data.frame(family_hist, male, age, cigarette, exercise, stress, grain, vegetable, meat, calories, alcohol, sugar)
heart_data <- data.frame(family_hist, male, age, cigarette, exercise, stress, grain, vegetable, meat, calories, alcohol, sugar, cholesterol, blood_press, sodium)
canc_data_vis <- canc_data
heart_data_vis <- heart_data

# normalize data
pre_canc_data <- preProcess(canc_data, method=c("center", "scale")) # save this object
canc_data <- predict(pre_canc_data, canc_data)
pre_heart_data <- preProcess(heart_data, method=c("center", "scale"))
heart_data <- predict(pre_heart_data, heart_data)

# calculate results
canc_result <- c()
for (i in seq(1: ncol(canc_data))) {
  canc_result <- cbind(canc_result, apply(canc_data[i], 2, FUN=function(x) x*cacn_w[i]))
}

heart_result <- c()
for (i in seq(1: ncol(heart_data))) {
  heart_result <- cbind(heart_result, apply(heart_data[i], 2, FUN=function(x) x*heart_w[i]))
}

canc_result2 <- scale(rowSums(canc_result))
heart_result2 <- scale(rowSums(heart_result))

# sigmoid function
sigmoid <- function(x) {
  (1 / (.5 + exp(-x))) * .4
}

# apply sigmoid function
risk_rate <- sapply(canc_result2, FUN=sigmoid)
canc_data <- cbind(canc_data, risk_rate)
canc_data_vis <- cbind(canc_data_vis, risk_rate)

risk_rate <- sapply(heart_result2, FUN=sigmoid)
heart_data <- cbind(heart_data, risk_rate)
heart_data_vis <- cbind(heart_data_vis, risk_rate)


########################### Save  ########################### 
write.csv(canc_data, file="Health_Advisor/data/canc_data.csv", row.names=FALSE)
write.csv(heart_data, file="Health_Advisor/data/heart_data.csv", row.names=FALSE)
write.csv(canc_data_vis, file="Health_Advisor/data/canc_data_vis.csv", row.names=FALSE)
write.csv(heart_data_vis, file="Health_Advisor/data/heart_data_vis.csv", row.names=FALSE)
saveRDS(pre_canc_data, file="Health_Advisor/data/pre_canc.rds")
saveRDS(pre_heart_data, file="Health_Advisor/data/pre_heart.rds")