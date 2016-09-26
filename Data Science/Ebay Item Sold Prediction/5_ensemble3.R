train <- head(full, nrow(eBayTrain))
train$sold <- factor(sold)
test <- tail(full, nrow(eBayTest))

cl <- makeCluster(8)
registerDoParallel(cl)
predictions <- c()
predictions <- foreach(m = 1:30, .combine = cbind) %dopar% {
     require(caret) # ML
     require(randomForest) # rf
     require(e1071) # svm
     require(xgboost) #xgboost
     require(Matrix)
     require(glmnet) # glmnet
     
     train.df <- train
     test.tf <- test
     target <- c('sold')
     predictors <- setdiff(names(train.df), target)
     
     # shuffle by row
     train.df <- train.df[sample(nrow(train.df)), ]
     submission <- T
     if (submission == T) {
          validation <- test.tf
          inTrain <- createDataPartition(y = train.df$sold, p = 0.7,list = FALSE)
          training <- train.df[inTrain, ]
          testing <- train.df[-inTrain, ]
     } else {
          inBuild <- createDataPartition(y = train.df$sold, p = 0.7,list = FALSE)
          validation <- train.df[-inBuild, ]
          buildData <- train.df[inBuild, ]
          
          inTrain <- createDataPartition(y = buildData$sold, p = 0.7,list = FALSE)
          training <- buildData[inTrain, ] 
          testing <- buildData[-inTrain, ]
     }
     
     
     ###########################################################
     # Modeling 01 with original data
     ###########################################################
     # rf (RandomForest)
     mdl.rf <- randomForest(sold ~ ., data = training,
                            replace = F, ntree = 700,
                            do.trace = F, keep.forest=TRUE)
     
     # svm (Support Vector Machine)
     mdl.svm <- svm(sold ~ ., data = training,
                    kernel = "radial", probability = TRUE,
                    cost = 2, gamma = 0.0625)
     
     # glm
     mdl.glm = glm(sold ~ ., data = training, family = 'binomial')
     
     # glmnnet
          train2 = training; test2 = testing
          train2$sold = NULL; test2$sold = NULL
          x = as.matrix(train2)
          mdl.glmn <- cv.glmnet(x, y = training$sold, alpha = 0.5, family = 'binomial',
                                nfolds = 10, type.measure="auc")
     
     # xgboost
     training.sparse <- sparse.model.matrix(sold ~ ., data = training)
     training.mtx <- xgb.DMatrix(data = training.sparse, 
                                 label = as.numeric(training$sold)-1, missing=NA)
     testing.sparse <- sparse.model.matrix(~ ., data = testing)
     testing.mtx <- xgb.DMatrix(data = testing.sparse)
     mdl.xgb <- xgboost(data = training.mtx, objective = "binary:logistic", 
                        nthread = 8, verbose = 0, nround = 84,
                        eta = .1, max.depth = 17)
     
     
     ###########################################################
     # Predicting 01 with testing data then combind prections
     ###########################################################
     pred.rf.test <- predict(mdl.rf, testing, type = "prob")
     pred.svm.test <- predict(mdl.svm, testing, probability = TRUE)
     pred.svm.test <- attr(pred.svm.test, "probabilities")
     pred.glm.test <- predict(mdl.glm, testing, type = "response")
     pred.glmn.test <- predict(mdl.glmn, as.matrix(test2), type="response", s = mdl.glmn$lambda.min)
     pred.xgb.test <- predict(mdl.xgb, testing.mtx)
     
     combinedTestData <- data.frame(
          pred.rf.test = pred.rf.test[,2],
          pred.svm.test = pred.svm.test[,2],
          pred.glm.test = round(pred.glm.test,8),
          # pred.glmn.test = pred.glmn.test[,1],
          pred.xgb.test = pred.xgb.test,
          sold = testing$sold)
     
     
     ###########################################################
     # Moelding 02 with combinded tested predictions
     ###########################################################
     comb.test.sparse <- sparse.model.matrix(sold ~ ., data = combinedTestData)
     comb.test.mtx <- xgb.DMatrix(data = comb.test.sparse, 
                                  label = as.numeric(combinedTestData$sold)-1, missing=NA)
     val.sparse <- sparse.model.matrix(~ ., data = validation)
     val.mtx <- xgb.DMatrix(data = val.sparse)
     
     comb.fit <- xgboost(data = comb.test.mtx, objective = "binary:logistic", 
                         nthread = 8, verbose = 0, nround = 84,
                         eta = .1, max.depth = 17)
     
     
     ###########################################################
     # Predicting 02 with validation data then combind prections
     ###########################################################
     pred.rf.val <- predict(mdl.rf, validation, type = "prob")
     pred.svm.val <- predict(mdl.svm, validation, probability = TRUE)
     pred.svm.val <- attr(pred.svm.val, "probabilities")
     pred.glm.val <- predict(mdl.glm, validation, type = "response")
     pred.glmn.val <- predict(mdl.glmn, as.matrix(validation), type="response", s = mdl.glmn$lambda.min)
     pred.xgb.val <- predict(mdl.xgb, val.mtx)
     
     combinedValData <- data.frame(
          pred.rf.val = pred.rf.val[,2],
          pred.svm.val = pred.svm.val[,2],
          pred.glm.val = round(pred.glm.val, 8),
          # pred.glmn.val = pred.glmn.val[,1],
          pred.xgb.val = pred.xgb.val)
     
     
     ###########################################################
     # Prediction 03 with combined validation data for the final
     ###########################################################
     comb.val.sparse <- sparse.model.matrix(~ ., data = combinedValData)
     comb.val.mtx <- xgb.DMatrix(data = comb.val.sparse)
     comb.pred.val <- predict(comb.fit, comb.val.mtx)
     
     predictions <- cbind(predictions, comb.pred.val)
     # comb.pred.val <- ifelse(comb.pred.val>.5,1,0)
     # t <- table(comb.pred.val, validation$sold)
     # sum(diag(t))/sum(t)
}
stopCluster(cl)
on.exit(stopCluster(cl))


# Cleaning Somedata
pred.df <- as.data.frame(predictions) 
pred.fin <- rowMeans(pred.df) #0.86494 0.86264

MySubmission <- data.frame(UniqueID = eBayTest$UniqueID, Probability1 = pred.fin) 
write.csv(MySubmission, "ensemble03.csv", row.names=FALSE)
