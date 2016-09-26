###########################################################################
# CV / Tuning
###########################################################################
cv.kfold.class <- function(data.df) {
     # data.df <- train
     target <- c('Survived')
     predictors <- setdiff(names(data.df), target)
   
     # Shuffling
     set.seed(1234)
     data.df <- data.df[sample(nrow(data.df)), ]
     
     acc.svm.total <- c(); acc.rf.total <- c(); acc.glm.total <- c();
     acc.xgb.total <- c(); acc.glmn.total <- c(); acc.bag.total <- c(); 
     acc.gbm.total <- c(); acc.knn.total <- c(); acc.rFrn.total <- c(); 
     # acc.rprt.total <- c();
     
     k <- 24 # k-fold cv
     # i <- 6
     for (i in 1:k) {
          print(paste('cv',i))
          idx <- (((i-1) * round((1/k)*nrow(data.df))) + 1):((i*round((1/k) * nrow(data.df))))
          training <- data.df[-idx,]
          testing <- data.df[idx,]
          
          # svm
          mdl.svm.cv = svm(Survived ~ .,data = training, gamma = 0.00390625, cost = 16, kernel = "radial")
          pred.svm.cv <- predict(mdl.svm.cv, testing)
          acc.svm.cv <- confusionMatrix(pred.svm.cv, testing$Survived)$overall["Accuracy"]
          acc.svm.total <- c(acc.svm.total, acc.svm.cv)
          
          # rf
          mdl.rf.cv <- randomForest(Survived ~ ., data = training,
                                    replace = F, ntree = 600,
                                    do.trace = F, keep.forest=TRUE)
          pred.rf.cv <- predict(mdl.rf.cv, testing)
          acc.rf.cv <- confusionMatrix(pred.rf.cv, testing$Survived)$overall["Accuracy"]
          acc.rf.total <- c(acc.rf.total, acc.rf.cv)
          
          # glm
          mdl.glm.cv = glm(Survived ~ ., data = training, family = binomial)          
          pred.glm.cv <- predict(mdl.glm.cv, testing, type = "response")
          pred.glm.cv <- ifelse(pred.glm.cv > .5, 1, 0)
          acc.glm.cv <- confusionMatrix(pred.glm.cv, testing$Survived)$overall["Accuracy"]
          acc.glm.total <- c(acc.glm.total, acc.glm.cv)
          
          # Data into matrix
          training.sparse <- sparse.model.matrix(Survived ~ ., data = training)
          training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$Survived) - 1, missing = NA)
          testing.sparse <- sparse.model.matrix(Survived ~ ., data = testing)
          testing.mtx <- xgb.DMatrix(data = testing.sparse)
          
          # xgboost (Extreme Gradient Boosting)
          param <- list(
               objective = "multi:softmax",     # multiclass classification 
               booster = "gbtree",              # gbtree or gblinear
               eta = 0.3,                       # lower value to avoid overfitting
               subsample = 0.5,                 # .5 for randome selctiong to avoid overfitting
               max_depth = 11,                  # maximum depth of tree, default 6
               nthread = 8,                     # number of threads to be used
               min_child_weight = 10,           # minimum sum of instance weight needed in a child
               silent = 0,
               num_class = 2)
          mdl.xgb.cv <- xgb.train(data = training.mtx, params = param, nrounds = 281)
          pred.xgb.cv <- factor(predict(mdl.xgb.cv, testing.mtx))
          acc.xgb.cv <- confusionMatrix(pred.xgb.cv, testing$Survived)$overall["Accuracy"]
          acc.xgb.total <- c(acc.xgb.total, acc.xgb.cv)
          
          # glmnet
          train2 = training; test2 = testing
          train2$Survived = NULL; test2$Survived = NULL
          x = as.matrix(train2)
          mdl.glmn.cv <- cv.glmnet(x, y = training$Survived, alpha = 0.7, family = 'binomial',
                                   nfolds = 10, type.measure = "auc")
          pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type = "response", s = mdl.glmn.cv$lambda.min)
          pred.glmn.cv <- ifelse(pred.glmn.cv[,1] > .5, 1, 0)
          acc.glmn.cv <- confusionMatrix(pred.glmn.cv, testing$Survived)$overall["Accuracy"]
          acc.glmn.total <- c(acc.glmn.total, acc.glmn.cv)
          
          #gbm
          fitControl <- trainControl(method = "adaptive_cv", number = 3, repeats = 3)
          mdl.gbm.cv <- train(Survived ~ ., data = training,  method = "gbm",
                              trControl = fitControl, verbose = FALSE)
          pred.gbm.cv <- predict(mdl.gbm.cv, testing)
          acc.gbm.cv <- confusionMatrix(pred.gbm.cv, testing$Survived)$overall["Accuracy"]
          acc.gbm.total <- c(acc.gbm.total, acc.gbm.cv)
          
          #knn
          pred.knn.cv <- knn(train = training[ ,predictors], test = testing[ ,predictors], 
                          cl = training[ ,target], k = 2)
               
          acc.knn.cv <- confusionMatrix(pred.knn.cv, testing$Survived)$overall["Accuracy"]
          acc.knn.total <- c(acc.knn.total, acc.knn.cv)
          
          # bag
          mdl.bag.cv <- bag(training[ ,predictors], training[ ,target],
                            bagControl = bagControl(fit = ctreeBag$fit,
                                                    predict = ctreeBag$pred,
                                                    aggregate = ctreeBag$aggregate,
                                                    allowParallel = TRUE))
          pred.bag.cv <- predict(mdl.bag.cv, testing)
          acc.bag.cv <- confusionMatrix(pred.bag.cv, testing$Survived)$overall["Accuracy"]
          acc.bag.total <- c(acc.bag.total, acc.bag.cv)
          
          # rFrn
          mdl.rFrn.cv <- rFerns(Survived ~ ., data = training)
          pred.rFrn.cv <- predict(mdl.rFrn.cv, testing)
          acc.rFrn.cv <- confusionMatrix(pred.rFrn.cv, testing$Survived)$overall["Accuracy"]
          acc.rFrn.total <- c(acc.rFrn.total, acc.rFrn.cv)
          
          # rpart
          # mdl.rprt.cv <- rpart(Survived ~ ., data = training, method = "class", cp = 0.5)
          # mdl.rprt.cv <- prune(mdl.rprt.cv, cp = 0.5)
          # pred.rprt.cv <- predict(mdl.rprt.cv, testing, type="class")
          # acc.rprt.cv <- confusionMatrix(pred.rprt.cv, testing$Survived)$overall["Accuracy"]
          # acc.rprt.total <- c(acc.rprt.total, acc.rprt.cv)
     }  
     summary.df <- data.frame(
          svm = mean(acc.svm.total), rf = mean(acc.rf.total),
          glm = mean(acc.glm.total), xgb = mean(acc.xgb.total),
          glmn = mean(acc.glmn.total), bag = mean(acc.bag.total),
          gbm = mean(acc.gbm.total), knn = mean(acc.knn.total),
          rFrn = mean(acc.rFrn.total))
     print(summary.df)
     print(rowMeans(summary.df))
}

cv.feat <- function() {
     train <- head(full, nrow(titanicTrain))
     test <- head(full, nrow(titanicTest))
     train$Survived <- factor(Survived)
     data.df <- train
     
     rfFuncs$summary <- twoClassSummary
     trainctrl <- trainControl(classProbs = TRUE, summaryFunction = twoClassSummary)
     control <- rfeControl(functions = rfFuncs, method = "repeatedcv", number = 5, repeats = 5, verbose = TRUE)
     results <- rfe(data.df[,!colnames(data.df) %in% c('Survived')], data.df$Survived, 
                    rfeControl = control, trControl = trainctrl , metric = "ROC",
                    sizes = seq(3,6, by = 1))
     plot(results, type=c("g", "o"))
     
     full <- full[,predictors(results)]
}

cv.tuned <- function () {
     train <- head(full, nrow(titanicTrain))
     test <- head(full, nrow(titanicTest))
     train$Survived <- factor(Survived)
     data.df <- train
     
     # knn (k)
     target <- c('Survived')
     predictors <- setdiff(names(data.df), target)
     k <- 6 # k-fold cv
     iterator0 = seq(2,10)
     acc.knn.total <- c()
     for (j in iterator0) {
        for (i in 1:k) {
           print(paste('cv',i))
           idx <- (((i-1) * round((1/k)*nrow(data.df))) + 1):((i*round((1/k) * nrow(data.df))))
           training <- data.df[-idx,]
           testing <- data.df[idx,]
           
           pred.knn.cv <- knn(train = training[ ,predictors], test = testing[ ,predictors], 
                              cl = training[ ,target], k = j)
           
           acc.knn.cv <- confusionMatrix(pred.knn.cv, testing$Survived)$overall["Accuracy"]
        }
        acc.knn.total <- c(acc.knn.total, mean(acc.knn.cv))
     }
     knn.cv.df <- data.frame(alpha = iterator0, accu = acc.knn.total)
     knn.cv.df <- knn.cv.df[order(-knn.cv.df[,"accu"]),]
     knn.cv.df
     
     # rf
     tuneRF(data.df, data.df$Survived, mtryStart = sqrt(ncol(data.df)), ntreeTry=13, stepFactor=1.5, improve=0.05,
            trace=TRUE, plot=TRUE, doBest=FALSE)
     
     # svm (gamma, cost)
     tuned.svm <- tune.svm(Survived ~ ., data = data.df, gamma = 2^(-8:0), cost = 2^(0:8), probability = FALSE)
     
     # xgb boost cv (nrounds)
     training.sparse <- sparse.model.matrix(Survived ~ ., data = data.df)
     training.mtx <- xgb.DMatrix(data = training.sparse, 
                                 label = as.numeric(data.df$Survived)-1, missing=NA)
     params <- list(objective = "multi:softmax", nthread = 8, num_class = 2,
                    nthread = 8, max.depth = 11, subsample = .5, num_class = 2,  
                    eta = .3, min_child_weight = 10)
     tuned.xgb <- xgb.cv(params = params, data = training.mtx, nrounds = 300, nfold = 30)
     nrounds.cv <- which(rowSums(tuned.xgb) == min(rowSums(tuned.xgb)))
     print(nrounds.cv)
     
     
     # xgb boost cv (max.depth, eta) 
     cv <- 3
     iterator1 <- seq(.3, .5, by = .1)
     iterator2 <- seq(9, 15)
     acc.xgb.total <- c()
     acc.cv.total <- c()
     cv.summary <- c()
     for (k in iterator1) {
          for (j in iterator2) {
               for (i in 1:cv) {
                    print(paste('cv',i,' eta',k,' child.wtd',j))
                    idx <- (((i-1) * round((1/cv)*nrow(data.df))) + 1):((i*round((1/cv) * nrow(data.df))))
                    training <- data.df[-idx,]
                    testing <- data.df[idx,]
                    
                    # Data into matrix
                    training.sparse <- sparse.model.matrix(Survived ~ ., data = training)
                    training.mtx <- xgb.DMatrix(data = training.sparse, 
                                                label = as.numeric(training$Survived) - 1, missing = NA)
                    testing.sparse <- sparse.model.matrix(Survived ~ ., data = testing)
                    testing.mtx <- xgb.DMatrix(data = testing.sparse)
                    mdl.xgb.cv <- xgboost(data = training.mtx, objective = "multi:softmax", 
                                          nthread = 8, verbose = 0, nround = nrounds.cv,
                                          eta = k, max.depth = 11, subsample = .5, 
                                          min_child_weight = j, num_class = 2)
                    pred.xgb.cv <- predict(mdl.xgb.cv, testing.mtx)
                    acc.xgb.cv <- confusionMatrix(pred.xgb.cv, testing$Survived)$overall["Accuracy"]
                    acc.xgb.total <- c(acc.xgb.total, acc.xgb.cv)
               }
               acc.cv.total <- c(acc.cv.total, mean(acc.xgb.total))
               temp <- data.frame(eta = k, child.wtd = j, acc.cv.total = mean(acc.cv.total))
               cv.summary <- rbind(cv.summary, temp)
          }
     }
     best.idx <- which(cv.summary$acc.cv.total == max(cv.summary[,'acc.cv.total']))
     cv.summary[best.idx,]
     
     
     # glmnet cv (alpha) 
     cv = 3
     i <- 2
     iterator3 <- seq(.1, 1, by = .1)
     acc.glmn.total <- c()
     for (j in iterator3) {
          for (i in 1:cv) {
               print(paste('cv',i))
               idx <- (((i-1) * round((1/cv)*nrow(data.df))) + 1):((i*round((1/cv) * nrow(data.df))))
               training <- data.df[-idx,]
               testing <- data.df[idx,]
               
               train2 = training; test2 = testing
               train2$Survived = NULL; test2$Survived = NULL
               x = as.matrix(train2)
               
               mdl.glmn.cv <- cv.glmnet(x, y = training$Survived, alpha = j, family = 'binomial',
                                        nfolds = 10, type.measure = "auc")
               pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type = "response", s = mdl.glmn.cv$lambda.min)
               pred.glmn.cv <- prediction(pred.glmn.cv[,1], testing$Survived)
               acc.glmn <- as.numeric(performance(pred.glmn.cv, "auc")@y.values)
          }
          acc.glmn.total <- c(acc.glmn.total, mean(acc.glmn))
     }
     glm.cv.df <- data.frame(alpha = iterator3, auc = acc.glmn.total)
     glm.cv.df <- glm.cv.df[order(-glm.cv.df[, "auc"]),] 
     glm.cv.df
     
     # rpart (cv)
     numFolds <- trainControl(method = "cv", number=10)
     cpGrid <- expand.grid(.cp = seq(0.01,0.5,0.01)) 
     train(Survived ~., data = data.df, method = "rpart", trControl = numFolds, tuneGrid = cpGrid)
     
     
}

cv.pca.nz <- function(cor.nz, full) {
     iterators <- seq(1, ncol(cor.nz))
     acc.total <- c()
     for (i in iterators) { 
          pre.proc.obj <- preProcess(cor.nz, method = c("pca") , pcaComp = i)
          pca.df <- predict(pre.proc.obj, cor.nz)
          full.cv <- cbind(full, pca.df)
          train <- head(full.cv, nrow(train))
          train$Survived <- factor(Survived)
          acc.total <- c(acc.total, cv.kfold.class(train))
     }
     result.pca <- cbind(iterators, acc.total)
     result.df <- result.pca[order(-result.pca[, "acc.total"]),] 
     print(result.df)
     best.num <- result.df[1,1]
     print(paste("Best number of PCA :",best.num))
}

cv.pca.full <- function(full) {
     iterators <- seq(1, ncol(full), by = 2)
     acc.total <- c()
     for (i in iterators) { 
          pre.proc.obj <- preProcess(full, method = c("pca") , pcaComp = i)
          print(paste("PCA :",i))
          pca.df <- predict(pre.proc.obj, full)
          full.cv <- cbind(full, pca.df)
          train <- head(full.cv, nrow(train))
          train$Survived <- factor(Survived)
          acc.total <- c(acc.total, cv.kfold.class(train))
     }
     result.pca <- cbind(iterators, acc.total)
     result.df <- result.pca[order(-result.pca[, "acc.total"]),] 
     print(result.df)
     best.num <- result.df[1,1]
     print(paste("Best number of PCA :",best.num))
     return(result.df)
}

cv.varImp <- function() {
     train <- head(full, nrow(titanicTrain))
     test <- head(full, nrow(titanicTest))
     train$Survived <- factor(Survived)
     train.tf <- train
     
     train.sparse.tf <- sparse.model.matrix(Survived ~ ., data = train.tf)
     train.mtx <- xgb.DMatrix(data = train.sparse.tf, label = as.numeric(train.tf$Survived) - 1, missing = NA)
     
     param <- list(
          objective = "multi:softmax",     # multiclass classification 
          booster = "gbtree",              # gbtree or gblinear
          eta = 0.1,                       # lower value to avoid overfitting
          subsample = 0.5,                 # .5 for randome selctiong to avoid overfitting
          max_depth = 11,                  # maximum depth of tree, default 6
          nthread = 8,                     # number of threads to be used
          gamma  = 0.1,                    # loss reduction required to make a further partition on leafe node
          colsample_bytree = 0.5,          # subsample ratio of columns when constructing each tree
          min_child_weight = 7,            # minimum sum of instance weight needed in a child
          silent = 0,
          num_class = length(levels(train.tf$Survived)))
     set.seed(1234)
     mdl.xgb <- xgb.train(data = train.mtx, params = param, nrounds = 100)
     
     target <- c('Survived')
     predictors <- setdiff(names(train.tf), target)
     
     # plot the important values
     imp.var.mtx <- xgb.importance(predictors, model = mdl.xgb)
     xgb.plot.importance(imp.var.mtx)
     
     # Removing unnecessary features by using CV
     acc.total2 <- c()
     iterators2 <- seq(0.002, 0.010, by = 0.002)
     for (i in iterators2) {
          col.remove <- subset(imp.var.mtx, imp.var.mtx$Gain < i)$Feature
          train.cv.prned <- train.tf[,!(names(train.tf) %in% col.remove)]
          acc.total2 <- c(acc.total2, cv.kfold(train.cv.prned))
     }
     result.prund <- cbind(iterators2, acc.total2)
     result.df2 <- result.prund[order(-result.prund[, "acc.total2"]),] 
     result.df2
     best.num2 <- result.df2[1,1]
     print(paste("Best threshold for Var Imp :",best.num2))
     
     col.remove <- subset(imp.var.mtx, imp.var.mtx$Gain < .014)$Feature
     full <- full[,!(names(full) %in% col.remove)]
}

###########################################################################
# Working Space
###########################################################################
train <- head(full, nrow(titanicTrain))
test <- head(full, nrow(titanicTest))
train$Survived <- factor(Survived)
cv.kfold.class(train)

###########################################################################
# Case Study
###########################################################################
# 1 original -> feat                                                                  
# 2 ragular                                                                           
# 3 ragular -> cluster -> feat                                                       
# 4 ragular -> cluster -> feat -> cluster -> feat                                    
# 5 ragular -> cluster                                                                
# 6 ragular -> cluster -> noNz                                                    
# 7 ragular -> cluster -> noNz -> noHicor                                           
# 8 ragular -> cluster -> noNz -> noHicor -> nzPCA4                                   
# 9 ragular -> cluster -> noNz -> noHicor  -> fullPCA16                              
# 10 ragular -> cluster -> noNz -> noHicor  -> fullPCA16 -> feat                      
# 11 ragular -> cluster -> fullPCA16                                                                                      
# 12 ragular -> cluster -> fullPCA16 -> noNz                                                                                      
# 13 ragular -> cluster -> fullPCA16 -> noNz -> noHicor                                                                                      
# 14 ragular -> cluster -> fullPCA16 -> noNz -> noHicor -> feat                                                                                   
# 15 ragular -> cluster -> fullPCAF                                
# 16 ragular -> cluster -> fullPCAF -> noNz                                
# 17 ragular -> cluster -> fullPCAF -> noNz -> noHicor                                
# 18 ragular -> cluster -> fullPCAF -> feat                                                                                     
# 19 ragular -> cluster -> fullPCAF -> feat -> cluster                                       
# 20 ragular -> cluster -> fullPCAF -> feat -> cluster -> feat                                       
# 21 ragular -> cluster -> fullPCAF -> feat -> cluster -> noNz                                       
# 22 ragular -> cluster -> fullPCAF -> feat -> cluster -> noNz -> noHicor   
# 23 ragular -> cluster -> noNz -> noHicor -> feat -> fullPCA                     0.848974
# 24 ragular -> cluster -> noNz -> noHicor -> fullPCA -> feat                     0.859859
# 26 ragular -> cluster -> noNz -> noHicor -> feat                             	  0.859359                               
# 27 ragular -> cluster -> noNz -> noHicor -> fullPCA -> impVar               
# 28 ragular -> cluster -> noNz -> noHicor -> fullPCA -> impVar -> feat               

###############################################################################################
# Loading / Saving Data
###############################################################################################
# write.csv(full, "data_3.csv", row.names=FALSE)
# write.csv(full, "data_4.csv", row.names=FALSE)
# write.csv(full, "data_7.csv", row.names=FALSE)
# write.csv(full, "data_10.csv", row.names=FALSE)
# write.csv(full, "data_14.csv", row.names=FALSE)
# write.csv(full, "data_18.csv", row.names=FALSE)
# write.csv(full, "data_20.csv", row.names=FALSE)
# write.csv(full, "data_23.csv", row.names=FALSE)
# write.csv(full, "data_24.csv", row.names=FALSE)
# write.csv(full, "data_25.csv", row.names=FALSE)
# write.csv(full, "data_26.csv", row.names=FALSE)
# write.csv(full, "data_27.csv", row.names=FALSE)
# write.csv(full, "data_28.csv", row.names=FALSE)
# write.csv(test.df, "test.df.csv", row.names=FALSE)
test.df <- read.csv("test.df.csv")
full <- read.csv("data_28.csv")
# 
library(caret)
intrain <- createDataPartition(y=full$Survived,p=0.8,list=FALSE)
training<-full[intrain,]
testing<-full[-intrain,]
write.csv(training, "train.csv", row.names=FALSE)
write.csv(testing, "test.csv", row.names=FALSE)

