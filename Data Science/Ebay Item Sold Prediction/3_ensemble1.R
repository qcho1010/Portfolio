
###############################################################################################
# Writing Submission
###############################################################################################
training <- head(full, nrow(eBayTrain))
training$sold <- factor(sold)
testing <- tail(full, nrow(eBayTest))

# SVC
mdl.svm.cv = svm(sold ~ .,data = training, gamma = 0.0625, cost = 2, kernel = "radial", probability = TRUE)
pred.svm.cv <- predict(mdl.svm.cv, testing, probability = TRUE)
pred.svm.cv <- attr(pred.svm.cv, "probabilities")
pred.svm.cv <- pred.svm.cv[,2]

# RF
mdl.rf.cv <- randomForest(sold ~ ., data = training,
                          replace = F, ntree = 600,
                          do.trace = F, keep.forest=TRUE)
pred.rf.cv <- predict(mdl.rf.cv, testing, type = "prob")
pred.rf.cv <- pred.rf.cv[,2]

training <- head(full, nrow(eBayTrain))
training$sold <- factor(sold)
testing <- tail(full, nrow(eBayTest))

# GLM
mdl.glm.cv <- glm(sold ~ ., data = training, family = binomial)          
pred.glm.cv <- predict(mdl.glm.cv, testing, type = "response")

# Data into matrix
training.sparse <- sparse.model.matrix(sold ~ ., data = training)
training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$sold) - 1, missing = NA)
testing.sparse <- sparse.model.matrix(~ ., data = testing)
testing.mtx <- xgb.DMatrix(data = testing.sparse)

# xgboost
mdl.xgb.cv <- xgboost(data = training.mtx, objective = "binary:logistic", 
                      nthread = 8, verbose = 0, nround = 84,
                      eta = .1, max.depth = 17)
pred.xgb.cv <- predict(mdl.xgb.cv, testing.mtx)

# glmnet
train2 = training; test2 = testing
train2$sold = NULL; test2$UniqueID = NULL
x = as.matrix(train2)
mdl.glmn.cv <- cv.glmnet(x, y = training$sold, alpha = 0.5, family = 'binomial',
                         nfolds = 10, type.measure="auc")
pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type="response", s = mdl.glmn.cv$lambda.min)
pred.glmn.cv <- pred.glmn.cv[,1]

#gbm
fitControl <- trainControl(method = "adaptive_cv",
                           number = 5,
                           repeats = 5)
mdl.gbm.cv <- train(sold ~ ., data = training,  method = "gbm",
                    trControl = fitControl, verbose = FALSE)
pred.gbm.cv <- predict(mdl.gbm, testing, type="prob")
pred.gbm.cv <- pred.gbm.cv[,2]

# Ensemble Model using multiple predictors
ensemble <- (pred.xgb.cv * 8 + pred.rf.cv * 7 + pred.svm.cv * 4 + pred.glmn.cv * 2 + 
                  pred.glm.cv * 2 + pred.gbm.cv * 18)/61 # 0.86860 0.86898 0.87108 0.87095 0.87194 0.8724
ensemble2 <- cbind(pred.xgb.cv, pred.rf.cv, pred.svm.cv, pred.glmn.cv, pred.glm.cv, pred.gbm.cv)
ensemble2 <- rowMeans(ensemble2)  # 0.87040  0.87042 0.87103 0.87128 0.87171 0.87196

MySubmission <- data.frame(UniqueID = eBayTest$UniqueID, Probability1 = ensemble2) 
write.csv(MySubmission, "ensemble01.csv", row.names=FALSE)