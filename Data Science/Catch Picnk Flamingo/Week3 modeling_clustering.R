library(dplyr)
library(tidyr)
setwd("C:/Users/Kyu/Documents/specialization/18-Unlock Value in Massive Datasets (University of California)/6-Capstone Project/big_data_capstone_datasets_and_scripts/combined-data")
comb <- read.csv("new-combined-data.csv", na.strings=c("NULL"))
comb$X <- NULL

############################################################
# Building Model
############################################################
# Random Forest
library(randomForest)
library(sampling)
library(caret)
library(e1071)

set.seed(2222)
idx <- createDataPartition(comb$buyerType, p = .6, list = FALSE)
train <- comb[idx, ]
test <- comb[-idx, ]

set.seed(2222)
mdl.rf <- randomForest(buyerType ~ ., 
                       data = train, replace = F, ntree = 600, do.trace = F, keep.forest = TRUE)

pred.rf <- predict(mdl.rf, test)
confusionMatrix(pred.rf, test$buyerType)$overall["Accuracy"]
varImp(mdl.rf)
varImpPlot(mdl.rf, type=2)


# Kmean
# convert factor variable
dummies_comb <- dummyVars( ~ platformType, data = comb, fullRank=T)
platform <- as.data.frame(predict(dummies_comb, comb))
comb$platformType <- NULL
comb <- cbind(comb, platform)

# normalize data frame
preproc_data <- preProcess(comb[,!names(comb) %in% c("buyerType", "userId")], method = c("center", "scale"))
comb_scaled <- predict(preproc_data, comb[,!names(comb) %in% c("buyerType", "userId")])

# Finding the best k (finding the 'elbow')
ratio_ss <- rep(0)
for (k in 1:7) {
    comb_km <- kmeans(comb_scaled, centers = k, nstart = 20)
    # Save the ratio between of WSS to TSS in kth element of ratio_ss
    ratio_ss[k] <- comb_km$tot.withinss/comb_km$totss
}
plot(ratio_ss, type="b", xlab="k")

# Build kmeans
set.seed(2222)
cluster <- kmeans(comb_scaled, centers = 3, nstart = 20)
comb_scaled$cluster <- cluster$cluster

set.seed(2222)
comb_scaled$buyerType <- comb$buyerType
comb_scaled$userId <- comb$userId
idx <- createDataPartition(comb_scaled$buyerType, p = .6, list = FALSE)
train <- comb_scaled[idx, ]
test <- comb_scaled[-idx, ]

set.seed(2222)
mdl.rf2 <- randomForest(buyerType ~. , 
                       data = train, replace = F, ntree = 600, do.trace = F, keep.forest = TRUE)
pred.rf2 <- predict(mdl.rf2, test)
confusionMatrix(pred.rf2, test$buyerType)$overall["Accuracy"]
varImp(mdl.rf2)
varImpPlot(mdl.rf2, type=2)

## Accuracy increased by 2~3 percents with kmean cluster feature

############################################################
# Cluster Exploration
############################################################
df <- comb_scaled %>%
    group_by(cluster) %>%
    summarise(teamLevel = mean(teamLevel), count_gameclicks = mean(count_gameclicks), 
              count_hits = mean(count_hits), hitRatio = mean(hitRatio), realLevel = mean(realLevel), sessionTraffic = mean(sessionTraffic))
as.data.frame(df)

