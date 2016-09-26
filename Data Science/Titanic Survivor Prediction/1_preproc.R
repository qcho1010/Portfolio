library(tm) # corpus
library(SnowballC) # corpus
library(caret)
library(ggplot2)
library(rpart)
library(flexclust)
library(caret) # ML
library(randomForest) # rf
library(e1071) # svm
library(class) # knn
library(ipred) # bag
library(xgboost) #xgboost
library(nnet) # nnet
library(rFerns) # rFern
library(rpart)  # rpart
library(gbm)  # rpart
library(glmnet) # glmnet
library(Rtsne) # 2d visualization
library(corrplot) # feature plot
library(Matrix)
library(parallel)
library(doParallel)
library(dbscan)
library(pROC)
library(ROCR)

setwd("E:/Google Drive/kaggle/01-titanic/data")
setwd("C:/Users/Kyu/Google Drive/kaggle/01-titanic/data")
ttrain <- read.csv("titanic_train.csv", na.strings=c(""))
titanicTest <- read.csv("titanic_test.csv", na.strings=c(""))

titanicTrain <- ttrain[complete.cases(ttrain$Embarked), ] 

# Combine train/test data for pre-processing
Survived <- titanicTrain$Survived
titanicTrain$Survived <- NULL
full <- NULL
full <- rbind(titanicTrain, titanicTest)
PassengerIdFull <- full$PassengerId
PassengerId <- titanicTest$PassengerId

################################################################
# Preprocessing
################################################################
# Fare
# simply replace the one missing Fare data with median, due to skewed distribution of Fare
full$Fare[is.na(full$Fare)] <- median(full$Fare, na.rm=T)
full$Fare[full$Fare == 0] <- .01

# Title
# Extract Title from Name
full$Title <- ifelse(grepl('Mr', full$Name),'Mr',
                     ifelse(grepl('Mrs', full$Name),'Mrs',
                            ifelse(grepl('Miss', full$Name),'Miss',
                                   'Nothing'))) 

# Adding Family Size
# Adding Family size because larger family tends to help each other
full$FamilySize <- ifelse(full$Parch + full$SibSp > 1, 1, 0)

# Sex
full$Sex <- ifelse(full$Sex == 'female', 1, 0)

full$Cabin <- as.character(full$Cabin)
full[is.na(full$Cabin), 'Cabin'] <- "Unknown" 

# Cabine
full$Cabin <- sapply(full$Cabin, function(x) substr(x, 1, 1))

# Age
# Use rpart to predict missing Age data
fit.Age <- rpart(Age[!is.na(Age)] ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize,
                 data = full[!is.na(full$Age), ], method = 'anova')
full$Age[is.na(full$Age)] <- predict(fit.Age, full[is.na(full$Age), ])

train <- head(full, nrow(titanicTrain))
train$Survived <- factor(Survived)
test <- tail(full, nrow(titanicTest))

# Ticket : Add variables depending on if ticket has alphabet or not
idx <- grepl("^[[:digit:][:alpha:]]+$", full$Ticket) 
full$ticketIdx <- idx
full$Ticket <- ifelse(full$ticketIdx == T, 1, 0) 
full$ticketIdx <- NULL

# Words Bag
full$Name <- as.character(full$Name)
CorpusDescription <- Corpus(VectorSource(full$Name))
CorpusDescription <- tm_map(CorpusDescription, content_transformer(tolower), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, PlainTextDocument, lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removePunctuation, lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removeWords, stopwords("english"), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removeWords, c("Mr", "Mrs", "Miss"), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, stemDocument, lazy=TRUE)
dtm <- DocumentTermMatrix(CorpusDescription)

words.df <- as.data.frame(as.matrix(dtm))
freq <- data.frame(wordCount = rowSums(words.df))
full <- cbind(full, freq)
full$Name <- NULL

# Adding Mother
# It increases the survival rate
full$Mother <- 0
full$Mother[full$Sex == 1 & full$Parch > 0 & full$Age > 16 & full$Title != 'Miss'] <- 1

# Adding Child
# It increases the survival rate
full$Child <- 0
full$Child[full$Age <= 16] <- 1


################################################################
# Feature Engineering
################################################################
# Fare
survivedTrain <- train[train$Survived == 1,]
fareMean_1 <- aggregate(Fare ~ Pclass + Sex + Age + Cabin + Embarked, data = survivedTrain, mean, na.rm = TRUE)
fareMean_2 <- aggregate(Fare ~ Pclass + Sex + Age + Cabin, data = survivedTrain, mean, na.rm = TRUE)
fareMean_3 <- aggregate(Fare ~ Pclass + Sex + Age, data = survivedTrain, mean, na.rm = TRUE)
fareMean_4 <- aggregate(Fare ~ Pclass + Sex, data = survivedTrain, mean, na.rm = TRUE)
colnames(fareMean_1)[6] <- "avg_fare_1"; colnames(fareMean_2)[5] <- "avg_fare_2"
colnames(fareMean_3)[4] <- "avg_fare_3"; colnames(fareMean_4)[3] <- "avg_fare_4"

df3 <- merge(full, fareMean_1, by = c ("Pclass", "Sex", "Age", "Cabin", "Embarked"), all.x = TRUE)
df3 <- merge(df3, fareMean_2, by = c ("Pclass", "Sex", "Age", "Cabin"), all.x = TRUE)
df3 <- merge(df3, fareMean_3, by = c ("Pclass", "Sex", "Age"), all.x = TRUE)
df3 <- merge(df3, fareMean_4, by = c ("Pclass", "Sex"), all.x = TRUE)

df3$avg_fare <- ifelse(is.na(df3$avg_fare_1) == FALSE, df3$avg_fare_1, df3$avg_fare_2)
df3$avg_fare <- ifelse(is.na(df3$avg_fare) == FALSE, df3$avg_fare, df3$avg_fare_3)
df3$avg_fare <- ifelse(is.na(df3$avg_fare) == FALSE, df3$avg_fare, df3$avg_fare_4)

df3$avg_fare_1 <- NULL; df3$avg_fare_2 <- NULL
df3$avg_fare_3 <- NULL; df3$avg_fare_4 <- NULL
full <- df3[order(df3$PassengerId), ]
full$PassengerId <- NULL

full$fareNorm <- round(full$Fare/full$avg_fare, 4) 
full[is.na(full$fareNorm) == TRUE, 'fareNorm'] <- 0
full$fareLog <- log(full$Fare)
full$fareExp <- exp(-full$Fare)
full$avgFareLog <- log(full$avg_fare)
full$avgFareExp <- exp(-full$avg_fare)

full$lowStart <- ifelse(full$fareNorm  < 1, 1, 0)


################################################################
# Dummify the variables
################################################################
full <- transform(full, Cabin = factor(Cabin), Title = factor(Title))
dummies <- dummyVars("~ Cabin + Embarked + Title", data = full, fullRank = T)
dummies.df <- as.data.frame(predict(dummies, full))
full$Cabin <- NULL; full$Embarked <- NULL; full$Title <- NULL
full$Ticket <- NULL; full$Name <- NULL;
full <- cbind(full, dummies.df)


################################################################
# Clustering variables
################################################################
k = 5
kosDist = dist(full, method = "euclidean")
hierCluster = hclust(kosDist, method="ward.D") 
hs.ec = cutree(hierCluster, k = k)

kosDist = dist(full, method = "maximum")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mx = cutree(hierCluster, k = k)

kosDist = dist(full, method = "manhattan")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mh = cutree(hierCluster, k = k)

kosDist = dist(full, method = "canberra")
hierCluster = hclust(kosDist, method="ward.D") 
hs.can = cutree(hierCluster, k = k)

kosDist = dist(full, method = "binary")
hierCluster = hclust(kosDist, method="ward.D") 
hs.bin = cutree(hierCluster, k = k)

kosDist = dist(full, method = "minkowski")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mink = cutree(hierCluster, k = k)

set.seed(10)
KmeansCluster = kmeans(full, centers = k)
km.kcca = as.kcca(KmeansCluster, full)
km.full = predict(km.kcca)

full <- cbind(full, km.full, hs.mink, hs.bin, hs.can, hs.mh, hs.mx, hs.ec)


################################################################
# PCA variables
################################################################
nzCol <- nearZeroVar(full, saveMetrics = TRUE)
full <- full[, nzCol$nzv == FALSE]

high.cor <- findCorrelation(cor(full), cutoff = .75)
full <- full[ ,-high.cor]

# Full PCA
pre.proc.obj <- preProcess(full, method = c("pca") , pcaComp = ncol(full))
pca.df <- predict(pre.proc.obj, full)
full <- cbind(full, pca.df)

# Normalize
preproc <- preProcess(full, method = c("center", "scale"))
full <- predict(preproc, full)


###############################################################################################
# checking missing vars.
###############################################################################################
data.frame(sapply(full, function(x) return(paste0(round(sum(is.na(x))/length(x), 4)*100,'%'))))

