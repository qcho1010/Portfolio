###############################################################################################
# Writing Submission
###############################################################################################

cl <- makeCluster(8)
registerDoParallel(cl)
predictions <- c()
predictions <- foreach(m = 1:50, .combine = cbind) %dopar% {
     library(caret) # ML
     library(randomForest) # rf
     library(e1071) # svm
     library(class) # knn
     library(ipred) # bag
     library(xgboost) #xgboost
     library(rFerns) # rFern
     library(gbm)  # gbm
     library(glmnet) # glmnet
     
     
     ###########################################################
     # Modeling 01 with original data
     ###########################################################
     full <- read.csv("data_7.csv")
     train.df <- head(full, nrow(titanicTrain))
     train.df$Survived <- factor(Survived)
     train.df <- train.df[sample(nrow(train.df)), ]
     inTrain <- createDataPartition(y = train.df$Survived, p = 0.7,list = FALSE)
     training <- train.df[inTrain, ]
     testing <- train.df[-inTrain, ]
     
     # ba
     target <- c('Survived')
     predictors <- setdiff(names(training), target)
     mdl.bag.cv <- bag(training[ ,predictors], training[ ,target],
                       bagControl = bagControl(fit = ctreeBag$fit,
                                               predict = ctreeBag$pred,
                                               aggregate = ctreeBag$aggregate))
     pred.bag.cv <- predict(mdl.bag.cv, testing)
     
     
     full <- read.csv("data_23.csv")
     train.df <- head(full, nrow(titanicTrain))
     train.df$Survived <- factor(Survived)
     train.df <- train.df[sample(nrow(train.df)), ]
     inTrain <- createDataPartition(y = train.df$Survived, p = 0.7,list = FALSE)
     training <- train.df[inTrain, ]
     testing <- train.df[-inTrain, ]
     
     # rf
     mdl.rf.cv <- randomForest(Survived ~ ., data = training,
                               replace = F, ntree = 600,
                               do.trace = F, keep.forest=TRUE)
     pred.rf.cv <- predict(mdl.rf.cv, testing)
     
     
     # xgb
     training.sparse <- sparse.model.matrix(Survived ~ ., data = training)
     training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$Survived) - 1, missing = NA)
     testing.sparse <- sparse.model.matrix( ~ ., data = testing)
     testing.mtx <- xgb.DMatrix(data = testing.sparse)

     testing.sparse <- sparse.model.matrix(~ ., data = testing)
     testing.mtx <- xgb.DMatrix(data = testing.sparse)
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
     pred.xgb.cv <- predict(mdl.xgb.cv, testing.mtx)
     
     #gbm
     fitControl <- trainControl(method = "adaptive_cv", number = 10, repeats = 10)
     mdl.gbm.cv <- train(Survived ~ ., data = training,  method = "gbm",
                         trControl = fitControl, verbose = FALSE)
     pred.gbm.cv <- predict(mdl.gbm.cv, testing)
     
     
     
     full <- read.csv("data_24.csv")
     train.df <- head(full, nrow(titanicTrain))
     train.df$Survived <- factor(Survived)
     train.df <- train.df[sample(nrow(train.df)), ]
     inTrain <- createDataPartition(y = train.df$Survived, p = 0.7,list = FALSE)
     training <- train.df[inTrain, ]
     testing <- train.df[-inTrain, ]
     
     # rFrn 
     mdl.rFrn.cv <- rFerns(Survived ~ ., data = training)
     pred.rFrn.cv <- predict(mdl.rFrn.cv, testing)
     
     
     full <- read.csv("data_25.csv")
     train.df <- head(full, nrow(titanicTrain))
     train.df$Survived <- factor(Survived)
     train.df <- train.df[sample(nrow(train.df)), ]
     inTrain <- createDataPartition(y = train.df$Survived, p = 0.7,list = FALSE)
     training <- train.df[inTrain, ]
     testing <- train.df[-inTrain, ]
     

     
     # glm
     mdl.glm.cv = glm(Survived ~ ., data = training, family = binomial)          
     pred.glm.cv <- predict(mdl.glm.cv, testing, type = "response")
     pred.glm.cv <- ifelse(pred.glm.cv > .5, 1, 0)
     
     
     # glmnet
     train2 = training; test2 = testing
     train2$Survived = NULL; test2$Survived = NULL
     x = as.matrix(train2)
     mdl.glmn.cv <- cv.glmnet(x, y = training$Survived, alpha = 0.7, family = 'binomial',
                              nfolds = 10, type.measure = "auc")
     pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type = "response", s = mdl.glmn.cv$lambda.min)
     pred.glmn.cv <- ifelse(pred.glmn.cv[,1] > .5, 1, 0)
     
     # svm
     mdl.svm.cv = svm(Survived ~ .,data = training, gamma = 0.00390625, cost = 16, kernel = "radial")
     pred.svm.cv <- predict(mdl.svm.cv, testing)
     
     
     full <- read.csv("data_26.csv")
     validation <- tail(full, nrow(titanicTest))
     train.df <- head(full, nrow(titanicTrain))
     train.df$Survived <- factor(Survived)
     train.df <- train.df[sample(nrow(train.df)), ]
     inTrain <- createDataPartition(y = train.df$Survived, p = 0.7,list = FALSE)
     training <- train.df[inTrain, ]
     testing <- train.df[-inTrain, ]
     
     #knn
     target <- c('Survived')
     predictors <- setdiff(names(training), target)
     pred.knn.cv <- knn(train = training[ ,predictors], test = testing[ ,predictors], 
                        cl = training[ ,target], k = 2)
     
     
     ###########################################################
     # Predicting 01 with testing data then combind prections
     ###########################################################
     
     # Ensemble Model using multiple predictors
     combinedTestData <- data.frame(
          pred.bag.cv = pred.bag.cv,
          pred.rf.cv = pred.rf.cv,
          pred.xgb.cv = pred.xgb.cv,
          pred.gbm.cv = pred.gbm.cv,
          pred.rFrn.cv = pred.rFrn.cv,
          pred.glm.cv = pred.glm.cv,
          pred.glmn.cv = pred.glmn.cv,
          pred.svm.cv = pred.svm.cv,
          pred.knn.cv = pred.knn.cv,
          Survived = testing$Survived)
     
     ###########################################################
     # Moelding 02 with combinded tested predictions
     ###########################################################
     
     comb.fit <- randomForest(Survived ~ ., data = combinedTestData,
                               replace = F, ntree = 600,
                               do.trace = F, keep.forest=TRUE)
     
     ###########################################################
     # Predicting 02 with validation data then combind prections
     ###########################################################
     full <- read.csv("data_7.csv")
     validation <- tail(full, nrow(titanicTest))
     pred.bag.cv2 <- predict(mdl.bag.cv, validation)
     
     full <- read.csv("data_23.csv")
     validation <- tail(full, nrow(titanicTest))
     pred.rf.cv2 <- predict(mdl.rf.cv, validation)
     
     validation.sparse <- sparse.model.matrix( ~ ., data = validation)
     validation.mtx <- xgb.DMatrix(data = validation.sparse)
     pred.xgb.cv2 <- factor(predict(mdl.xgb.cv, validation.mtx))
     
     pred.gbm.cv2 <- predict(mdl.gbm.cv, validation)
     
     full <- read.csv("data_24.csv")
     validation <- tail(full, nrow(titanicTest))
     pred.rFrn.cv2 <- predict(mdl.rFrn.cv, validation)
     
     full <- read.csv("data_25.csv")
     validation <- tail(full, nrow(titanicTest))
     pred.glm.cv2 <- predict(mdl.glm.cv, validation, type = "response")
     pred.glm.cv2 <- ifelse(pred.glm.cv2 > .5, 1, 0)
     
     pred.glmn.cv2 <- predict(mdl.glmn.cv, as.matrix(validation), type = "response", s = mdl.glmn.cv$lambda.min)
     pred.glmn.cv2 <- ifelse(pred.glmn.cv2[,1] > .5, 1, 0)
     
     pred.svm.cv2 <- predict(mdl.svm.cv, validation)
     
     full <- read.csv("data_26.csv")
     validation <- tail(full, nrow(titanicTest))
     pred.knn.cv2 <- knn(train = training[ ,predictors], test = validation[ ,predictors], 
                        cl = training[ ,target], k = 2)
     
     combinedValData <- data.frame(
               pred.bag.cv = pred.bag.cv2,
               pred.rf.cv = pred.rf.cv2,
               pred.xgb.cv = pred.xgb.cv2,
               pred.gbm.cv = pred.gbm.cv2,
               pred.rFrn.cv = pred.rFrn.cv2,
               pred.glm.cv = pred.glm.cv2,
               pred.glmn.cv = pred.glmn.cv2,
               pred.svm.cv = pred.svm.cv2,
               pred.knn.cv = pred.knn.cv2)
     
     ###########################################################
     # Prediction 03 with combined validation data for the final
     ###########################################################
     comb.pred.val <- predict(comb.fit, combinedValData)
     
     predictions <- cbind(predictions, comb.pred.val)
     # comb.pred.val <- ifelse(comb.pred.val>.5,1,0)
     # t <- table(comb.pred.val, validation$Survived)
     # sum(diag(t))/sum(t)
}
stopCluster(cl)
on.exit(stopCluster(cl))


pred.df <- as.data.frame(t(predictions))

pred.wted <- c()  # wegihted prediction
for (i in seq(1, length(pred.df), 1)) {
     pred.tbl.df <- as.data.frame(table(pred.df[,i])) 
     idx <- which(pred.tbl.df$Freq == max(pred.tbl.df$Freq))
     pred.wted <- c(pred.wted, as.vector(pred.tbl.df[idx,]$Var1[1]))
}
pred.wted <- as.numeric(pred.wted)-1
MySubmission <- data.frame(PassengerId = PassengerId, Survived = pred.wted) 
write.csv(MySubmission, "ensemble03.csv", row.names=FALSE) # 0.75598, 
