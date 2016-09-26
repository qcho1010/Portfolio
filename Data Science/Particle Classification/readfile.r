library(ggplot2)
testdata <- read.csv(file="seaflow_21min.csv",head=TRUE,sep=",")
summary(testdata)
broj <-nrow(testdata)
broj
size <-floor(0.75*nrow(testdata))
size
size2 <- length(testdata)
size2
split_p <- sample(nrow(testdata),1) #take a random split point
split_p
srednja_ukupna <-mean(testdata$time)
srednja_ukupna
train <- testdata[1:split_p, ]
srednja_train <-mean(train$time)
srednja_train

test <- testdata[split_p+1:nrow(testdata),]
srednja_test <-mean(test$time)
srednja_test

print(ggplot(testdata$pe,testdata$chl_small,col=testdata$pop))

srednja_train
