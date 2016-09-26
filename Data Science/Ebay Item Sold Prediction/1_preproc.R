library(tm) # corpus
library(SnowballC) # corpus
library(caret)
library(ggplot2)
library(rpart)
library(flexclust) #kcca
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
################################################################
setwd("E:/Google Drive/kaggle/data")
eBayTrain = read.csv("eBayiPadTrain.csv",stringsAsFactors = FALSE)
eBayTest = read.csv("eBayiPadTest.csv", stringsAsFactors = FALSE)

eBayTrain[which(eBayTrain$productline=="iPad 5"),"productline"] = "iPad Air"
eBayTrain[which(eBayTrain$productline=="iPad mini Retina"),"productline"] = "iPad mini 2"

# Combine train/test data for pre-processing
sold <- eBayTrain$sold
eBayTrain$sold <- NULL
full <- NULL
full <- rbind(eBayTrain, eBayTest)
UniqueID <- eBayTest$UniqueID

full <- transform(full,
                 condition = factor(condition),
                 cellular = factor(cellular),
                 carrier = factor(carrier),
                 color = factor(color),
                 storage = factor(storage),
                 productline = factor(productline)
)

################################################################
# Calculating Avg market prices for each pruduct.
################################################################
train <- head(full, nrow(eBayTrain))
train$sold <- factor(sold)
test <- tail(full, nrow(eBayTest))

eBayTrain_new = train[train$biddable == 0 & train$sold == 1,]
ak_cps <- aggregate(startprice ~ storage + condition + productline, data = eBayTrain_new, mean, na.rm = TRUE)
ak_cp <- aggregate(startprice ~ productline + condition, data = eBayTrain_new, mean, na.rm = TRUE)
ak_condition <- aggregate(startprice ~ condition, data = eBayTrain_new, mean, na.rm = TRUE)
ak_productline_used <- aggregate(startprice ~ productline, data = eBayTrain_new[eBayTrain_new$condition == "Used",], mean, na.rm = TRUE)
colnames(ak_cps)[4] <- "avg_price_cps"
colnames(ak_cp)[3] <- "avg_price_cp"
colnames(ak_productline_used)[2] <- "avg_price_p_used"

# per_used_price is the avg prices ratio between given condition and "Used" condition
ak_condition$per_used_price <- ak_condition$startprice / ak_condition[ak_condition$condition == "Used","startprice"]
ak_condition$startprice <- NULL

df3 <- merge(full, ak_cps, by = c ("productline", "condition", "storage"), all.x = TRUE)
df3 <- merge(df3, ak_cp, by = c("productline","condition"), all.x = TRUE)
df3 <- merge(df3, ak_productline_used, by = c("productline"), all.x = TRUE)
df3 <- merge(df3, ak_condition, by = c("condition"), all.x = TRUE)

# calc_price = avg price for a given productline (only condition=="Used" included)
df3$calc_price <- df3$avg_price_p_used * df3$per_used_price

df3$avg_price_cp1 <- ifelse(is.na(df3$avg_price_cps) == FALSE, df3$avg_price_cps, df3$avg_price_cp)
df3$avg_price_cp2 <- ifelse(is.na(df3$avg_price_cp1) == FALSE, df3$avg_price_cp1, df3$calc_price)
df3$norm_price <- (df3$startprice/df3$avg_price_cp2)
df3 <- df3[order(df3$UniqueID), ]
df3$avg_price_cps <- NULL
df3$avg_price_cp <- NULL
df3$avg_price_cp1 <- NULL

full <- df3
full$UniqueID <- NULL 

################################################################
# Words Bag
################################################################
CorpusDescription <- Corpus(VectorSource(full$description))
CorpusDescription <- tm_map(CorpusDescription, content_transformer(tolower), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, PlainTextDocument, lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removePunctuation, lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removeWords, stopwords("english"), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, removeWords, c("appl", "apple", "ipad", "item"), lazy=TRUE)
CorpusDescription <- tm_map(CorpusDescription, stemDocument, lazy=TRUE)
dtm <- DocumentTermMatrix(CorpusDescription)
sparse <- removeSparseTerms(dtm, 0.990)
words.df <- as.data.frame(as.matrix(sparse))

# Remove unnecessary variables
colnames(words.df) <- make.names(colnames(words.df))
words.df$condit <- NULL; words.df$may <- NULL
words.df$come <- NULL ; words.df$doe <- NULL
words.df$devic <- NULL; words.df$function. <- NULL
words.df$one <- NULL; words.df$onli <- NULL
words.df$pleas <- NULL; words.df$read <- NULL
words.df$scratch <- NULL; words.df$see <- NULL
words.df$show <- NULL; words.df$still <- NULL
words.df$tab <- NULL; words.df$the <- NULL
words.df$this <- NULL; words.df$veri <- NULL
words.df$will <- NULL; words.df$ipad <- NULL
words.df$has <- NULL; words.df$list <- NULL
words.df$light <- NULL; words.df$like <- NULL
words.df$unit <- NULL; words.df$back <- NULL

freq <- data.frame(wordCount = rowSums(words.df))
full <- cbind(full, freq)
full <- cbind(full, words.df)
full$description <- NULL

################################################################
# Data transformed Variables
################################################################
full$lowStart <- ifelse(full$norm_price  < 1, 1, 0)
full$startPriceLog <- log(full$startprice)
full$startPriceExp <- exp(-full$startprice)
full$predPriceLog <- log(full$avg_price_cp2)
full$predPriceExp <- exp(-full$avg_price_cp2)

################################################################
# Dummify the variables
################################################################
# Factorize all character vairables
# dummies <- dummyVars("~ storage + cellular + condition + carrier + color + productline", 
                     # data = full, fullRank = T)
dummies <- dummyVars("~ storage + condition + productline", 
                     data = full, fullRank = T)
dummies.df <- as.data.frame(predict(dummies, full))
full$storage <- NULL
full$condition <- NULL
full$productline <- NULL
full$cellular <- NULL
full$carrier <- NULL
full$color <- NULL
full$avg_price_p_used <- NULL
full$per_used_price <- NULL
full$calc_price <- NULL
full$avg_price_cp2 <- NULL
full$description <- NULL

full <- cbind(full, dummies.df)
tidy.name.vector <- make.names(colnames(full), unique = TRUE)
names(full) <- tidy.name.vector

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
# copy <- full
# full <- copy
# full <- cbind(full, km.full, hs.mink, hs.bin, hs.can, hs.mh, hs.mx, hs.ec, dummies.df,  words.df)
# tidy.name.vector <- make.names(colnames(full), unique = TRUE)
# names(full) <- tidy.name.vector

proc <- c('avg_price_p_used','startprice','calc_price','avg_price_cp2')
pre.proc.obj <- preProcess(full[,proc], method = c("center", "scale"))
pca.df <- predict(pre.proc.obj, full[,proc])
full <- full[,!colnames(full) %in% proc]
full <- cbind(full, pca.df)

# predictors <- cv.feat(train)

# Remove highly correlated variables
high.cor <- findCorrelation(cor(full), cutoff = .75)
high.cor.df <- full[ ,high.cor]
full <- full[ ,-high.cor]

# Remove near zero variance variables
nzCol <- nearZeroVar(full, saveMetrics = TRUE)
nz.df <- full[, nzCol$nzv == TRUE]
full <- full[, nzCol$nzv == FALSE]

# Combind data set with high correlated df, zero variability df to make perform PCA
# cor.nz  <- cbind(high.cor.df, nz.df)
# cv.pca(cor.nz, full)
# pre.proc.obj <- preProcess(cor.nz, method = c("center", "scale", "pca") , pcaComp = ncol(cor.nz))
# pca.df <- predict(pre.proc.obj, cor.nz)

# copy <- full
# full <- copy
# full <- cbind(full, pca.df)
# cv.varImp(train)

################################################################
# Feature selection
################################################################
train <- head(full, nrow(eBayTrain))
train$sold <- factor(sold)

predictors <- cv.feat(train)
# predictorsSave <- predictors
# predictors <- predictors(results)
full <- full[, predictors]
