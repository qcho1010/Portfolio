###############################################################################################
# Writing Submission
###############################################################################################
full <- read.csv("data_7.csv")
training <- head(full, nrow(titanicTrain))
training$Survived <- factor(Survived)
testing <- tail(full, nrow(titanicTest))

target <- c('Survived')
predictors <- setdiff(names(training), target)

# bag
mdl.bag.cv <- bag(training[ ,predictors], training[ ,target],
                  bagControl = bagControl(fit = ctreeBag$fit,
                                          predict = ctreeBag$pred,
                                          aggregate = ctreeBag$aggregate,
                                          allowParallel = TRUE))
pred.bag.cv <- predict(mdl.bag.cv, testing)


full <- read.csv("data_23.csv")
training <- head(full, nrow(titanicTrain))
testing <- tail(full, nrow(titanicTest))
training$Survived <- as.factor(Survived)
training$PassengerId <- NULL

# rf
mdl.rf.cv <- randomForest(Survived ~ ., data = training,
                          replace = F, ntree = 600,
                          do.trace = F, keep.forest=TRUE)
pred.rf.cv <- predict(mdl.rf.cv, testing)

# xgb
# Data into matrix
training.sparse <- sparse.model.matrix(Survived ~ ., data = training)
training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$Survived) - 1, missing = NA)
testing.sparse <- sparse.model.matrix( ~ ., data = testing)
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

# gbm
fitControl <- trainControl(method = "adaptive_cv", number = 10, repeats = 10)
mdl.gbm.cv <- train(Survived ~ ., data = training,  method = "gbm",
                    trControl = fitControl, verbose = FALSE)
pred.gbm.cv <- predict(mdl.gbm.cv, testing)


full <- read.csv("data_24.csv")
training <- head(full, nrow(titanicTrain))
training$Survived <- factor(Survived)
testing <- tail(full, nrow(titanicTest))

# rFrn (Random Ferns Classifier)
mdl.rFrn.cv <- rFerns(Survived ~ ., data = training)
pred.rFrn.cv <- predict(mdl.rFrn.cv, testing)


full <- read.csv("data_25.csv")
training <- head(full, nrow(titanicTrain))
training$Survived <- factor(Survived)
testing <- tail(full, nrow(titanicTest))
target <- c('Survived')
predictors <- setdiff(names(training), target)

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
training <- head(full, nrow(titanicTrain))
training$Survived <- factor(Survived)
testing <- tail(full, nrow(titanicTest))
target <- c('Survived')
predictors <- setdiff(names(training), target)

# knn
pred.knn.cv <- knn(train = training[ ,predictors], test = testing[ ,predictors], 
                   cl = training[ ,target], k = 2)



# Ensemble Model using multiple predictors
predictions <- data.frame(
     pred.bag.cv = pred.bag.cv,
     pred.rf.cv = pred.rf.cv,
     pred.xgb.cv = pred.xgb.cv,
     pred.gbm.cv = pred.gbm.cv,
     pred.rFrn.cv = pred.rFrn.cv,
     pred.glm.cv = pred.glm.cv,
     pred.glmn.cv = pred.glmn.cv,
     pred.svm.cv = pred.svm.cv,
     pred.knn.cv = pred.knn.cv)
pred.df <- as.data.frame(t(predictions))

pred.wted <- c()  # wegihted prediction
for (i in seq(1, length(pred.df), 1)) {
     pred.tbl.df <- as.data.frame(table(pred.df[,i])) 
     idx <- which(pred.tbl.df$Freq == max(pred.tbl.df$Freq))
     pred.wted <- c(pred.wted, as.vector(pred.tbl.df[idx,]$Var1[1]))
}

MySubmission <- data.frame(PassengerId = PassengerId, Survived = pred.rf.cv) 
write.csv(MySubmission, "ensembleImpVar.csv", row.names=FALSE) # 0.76555


