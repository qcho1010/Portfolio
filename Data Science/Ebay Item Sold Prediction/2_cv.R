cv.kfold.prob <- function(data.df) {
     # data.df <- train
     target <- c('sold')
     predictors <- setdiff(names(data.df), target)
  
     # Shuffling
     set.seed(1234)
     data.df <- data.df[sample(nrow(data.df)), ]
     
     acc.svm.total <- c(); acc.rf.total <- c(); acc.gbm.total <- c();
     acc.glm.total <- c(); acc.xgb.total <- c(); acc.glmn.total <- c() 
     
     k <- 5 # k-fold cv
     # i <- 3
     for (i in 1:k) {
          print(paste('cv',i))
          idx <- (((i-1) * round((1/k)*nrow(data.df))) + 1):((i*round((1/k) * nrow(data.df))))
          training <- data.df[-idx,]
          testing <- data.df[idx,]
          
          # SVM
          # mdl.svm.cv = svm(sold ~ ., data = training, kernel = "radial")
          mdl.svm.cv = svm(sold ~ .,data = training, gamma = 0.0625, cost = 2, kernel = "radial", probability = TRUE)
          pred.svm.cv <- predict(mdl.svm.cv, testing, probability = TRUE)
          pred.svm.cv <- attr(pred.svm.cv, "probabilities")
          pred.svm.cv <- prediction(pred.svm.cv[,2], testing$sold)
          acc.svm.cv <- as.numeric(performance(pred.svm.cv, "auc")@y.values)
          acc.svm.total <- c(acc.svm.total, acc.svm.cv)
          
          # RF
          mdl.rf.cv <- randomForest(sold ~ ., data = training,
                                    replace = F, ntree = 600,
                                    do.trace = F, keep.forest=TRUE)
          pred.rf.cv <- predict(mdl.rf.cv, testing, type = "prob")
          pred.rf.cv <- prediction(pred.rf.cv[,2], testing$sold)
          acc.rf.cv <- as.numeric(performance(pred.rf.cv, "auc")@y.values)
          acc.rf.total <- c(acc.rf.total, acc.rf.cv)
          
          # GLM
          mdl.glm.cv <- glm(sold ~ ., data = training, family = binomial)          
          pred.glm.cv <- predict(mdl.glm.cv, testing, type = "response")
          pred.glm.cv <- prediction(pred.glm.cv, testing$sold)
          acc.glm.cv <- as.numeric(performance(pred.glm.cv, "auc")@y.values)
          acc.glm.total <- c(acc.glm.total, acc.glm.cv)
          
          # Data into matrix
          training.sparse <- sparse.model.matrix(sold ~ ., data = training)
          training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$sold) - 1, missing = NA)
          testing.sparse <- sparse.model.matrix(sold ~ ., data = testing)
          testing.mtx <- xgb.DMatrix(data = testing.sparse)
          
          # xgboost (Extreme Gradient Boosting)
          mdl.xgb.cv <- xgboost(data = training.mtx, objective = "binary:logistic", 
                                nthread = 8, verbose = 0, nround = 84,
                                eta = .1, max.depth = 17)
          pred.xgb.cv <- predict(mdl.xgb.cv, testing.mtx)
          pred.xgb.cv <- prediction(pred.xgb.cv, testing$sold)
          acc.xgb.cv <- as.numeric(performance(pred.xgb.cv, "auc")@y.values)
          acc.xgb.total <- c(acc.xgb.total, acc.xgb.cv)
          
          # glmnet
          train2 = training; test2 = testing
          train2$sold = NULL; test2$sold = NULL
          x = as.matrix(train2)
          mdl.glmn.cv <- cv.glmnet(x, y = training$sold, alpha = 0.5, family = 'binomial',
                                   nfolds = 10, type.measure="auc")
          pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type="response", s = mdl.glmn.cv$lambda.min)
          pred.glmn.cv <- pred.glmn.cv[,1]
          pred.glmn.cv <- prediction(pred.glmn.cv, testing$sold)
          acc.glmn.cv <- as.numeric(performance(pred.glmn.cv, "auc")@y.values)
          acc.glmn.total <- c(acc.glmn.total, acc.glmn.cv)
          
          #gbm
          fitControl <- trainControl(method = "adaptive_cv",
                                     number = 5,
                                     repeats = 5)
          mdl.gbm.cv <- train(sold ~ ., data = training,  method = "gbm",
                              trControl = fitControl, verbose = FALSE)
          pred.gbm.cv <- predict(mdl.gbm.cv, testing, type="prob")
          pred.gbm.cv <- pred.gbm.cv[,2]
          pred.gbm.cv <- prediction(pred.gbm.cv, testing$sold)
          acc.gbm.cv <- as.numeric(performance(pred.gbm.cv, "auc")@y.values)
          acc.gbm.total <- c(acc.gbm.total, acc.gbm.cv)
          
     }  
     summary.df <- data.frame(
          svm = mean(acc.svm.total), rf = mean(acc.rf.total),
          glm = mean(acc.glm.total), xgb = mean(acc.xgb.total),
          glmn = mean(acc.glmn.total), gbm = mean(acc.gbm.total))
     print(summary.df)
     print(rowMeans(summary.df))
     return(summary.df)
}

cv.kfold.class <- function(data.df) {
     # data.df <- train
     target <- c('sold')
     predictors <- setdiff(names(data.df), target)

     # Shuffling
     set.seed(1234)
     data.df <- data.df[sample(nrow(data.df)), ]

     acc.svm.total <- c(); acc.rf.total <- c()
     acc.glm.total <- c(); acc.xgb.total <- c(); acc.glmn.total <- c() 
     
      k <- 5 # k-fold cv
      # i <- 3
     for (i in 1:k) {
          print(paste('cv',i))
          idx <- (((i-1) * round((1/k)*nrow(data.df))) + 1):((i*round((1/k) * nrow(data.df))))
          training <- data.df[-idx,]
          testing <- data.df[idx,]
          
          # SVM
          # mdl.svm.cv = svm(sold ~ ., data = training, kernel = "radial")
          mdl.svm.cv = svm(sold ~ .,data = training, gamma = 0.0625, cost = 2, kernel = "radial")
          pred.svm.cv <- predict(mdl.svm.cv, testing)
          acc.svm.cv <- confusionMatrix(pred.svm.cv, testing$sold)$overall["Accuracy"]
          acc.svm.total <- c(acc.svm.total, acc.svm.cv)
          
          # RF
          mdl.rf.cv <- randomForest(sold ~ ., data = training,
                                 replace = F, ntree = 600,
                                 do.trace = F, keep.forest=TRUE)
          pred.rf.cv <- predict(mdl.rf.cv, testing)
          acc.rf.cv <- confusionMatrix(pred.rf.cv, testing$sold)$overall["Accuracy"]
          acc.rf.total <- c(acc.rf.total, acc.rf.cv)
          
          # GLM
          mdl.glm.cv = glm(sold ~ ., data = training, family = binomial)          
          pred.glm.cv <- predict(mdl.glm.cv, testing, type = "response")
          pred.glm.cv <- ifelse(pred.glm.cv > .5, 1, 0)
          acc.glm.cv <- confusionMatrix(pred.glm.cv, testing$sold)$overall["Accuracy"]
          acc.glm.total <- c(acc.glm.total, acc.glm.cv)
          
          # Data into matrix
          training.sparse <- sparse.model.matrix(sold ~ ., data = training)
          training.mtx <- xgb.DMatrix(data = training.sparse, label = as.numeric(training$sold) - 1, missing = NA)
          testing.sparse <- sparse.model.matrix(sold ~ ., data = testing)
          testing.mtx <- xgb.DMatrix(data = testing.sparse)
          
          # xgboost (Extreme Gradient Boosting)
          mdl.xgb.cv <- xgboost(data = training.mtx, objective = "multi:softmax", 
                                nthread = 8, verbose = 0, num_class = 2, 
                                nround = 84, eta = .1, max.depth = 17)
          pred.xgb.cv <- factor(predict(mdl.xgb.cv, testing.mtx))
          acc.xgb.cv <- confusionMatrix(pred.xgb.cv, testing$sold)$overall["Accuracy"]
          acc.xgb.total <- c(acc.xgb.total, acc.xgb.cv)
          
     }  
     summary.df <- data.frame(
          svm = mean(acc.svm.total), rf = mean(acc.rf.total),
          glm = mean(acc.glm.total), xgb = mean(acc.xgb.total))
     print(summary.df)
     print(rowMeans(summary.df))
     return(rowMeans(summary.df))
}

cv.feat <- function(data.df) {
     rfFuncs$summary <- twoClassSummary
     trainctrl <- trainControl(classProbs = TRUE, summaryFunction = twoClassSummary)
     control <- rfeControl(functions = rfFuncs, method = "repeatedcv", number = 5, repeats = 5, verbose = TRUE)
     results <- rfe(data.df[,!colnames(data.df) %in% c('sold')], data.df$sold, 
                    rfeControl = control, trControl = trainctrl , metric="ROC",
                    sizes = c(4,8,10,16,20,22,24,26,28,32,34,38,42,48,50,54,56,60,80,192))
     plot(results, type=c("g", "o"))
#      results <- rfe(data.df[,!colnames(data.df) %in% c('sold')], data.df$sold, 
#                     rfeControl = control, trControl = trainctrl , metric="ROC",
#                     sizes = seq(18,19))
     # results <- results$results[1:5,]
     # plot(results$Variables, results$ROC)
     return(predictors(results))
}

cv.pca.nz <- function(cor.nz, full) {
     iterators <- seq(1, ncol(cor.nz))
     acc.total <- c()
     for (i in iterators) { 
          pre.proc.obj <- preProcess(cor.nz, method = c("pca") , pcaComp = i)
          pca.df <- predict(pre.proc.obj, cor.nz)
          full.cv <- cbind(full, pca.df)
          train <- head(full.cv, nrow(train))
          train$sold <- factor(sold)
          acc.total <- c(acc.total, cv.kfold(train))
     }
     result.pca <- cbind(iterators, acc.total)
     result.df <- result.pca[order(-result.pca[, "acc.total"]),] 
     print(result.df)
     best.num <- result.df[1,1]
     print(paste("Best number of PCA :",best.num))
}

cv.pca.full <- function(full) {
     iterators <- seq(2, ncol(full), by = 5)
     acc.total <- c()
     for (i in iterators) { 
          pre.proc.obj <- preProcess(full, method = c("pca") , pcaComp = i)
          pca.df <- predict(pre.proc.obj, full)
          full.cv <- cbind(full, pca.df)
          train <- head(full.cv, nrow(train))
          train$sold <- factor(sold)
          acc.total <- c(acc.total, cv.kfold(train))
     }
     result.pca <- cbind(iterators, acc.total)
     result.df <- result.pca[order(-result.pca[, "acc.total"]),] 
     print(result.df)
     best.num <- result.df[1,1]
     print(paste("Best number of PCA :",best.num))
     return(result.df)
}

cv.varImp <- function (data.df) {
     param <- list(
          objective = "multi:softmax",     # multiclass classification 
          booster = "gbtree",              # gbtree or gblinear
          eta = 0.1,                       # lower value to avoid overfitting
          subsample = 0.5,                 # .5 for randome selctiong to avoid overfitting
          max_depth = 11,                  # maximum depth of tree, default 6
          nthread = 8,                     # number of threads to be used
          gamma  = 0.1,                    # loss reduction required to make a further partition on leafe node
          eta = 0.02,                      # step size shrinkage, control the learning rate
          colsample_bytree = 0.5,          # subsample ratio of columns when constructing each tree
          min_child_weight = 7,            # minimum sum of instance weight needed in a child
          silent = 0,
          num_class = 2)
     data.df <- train
     train.sparse.tf <- sparse.model.matrix(sold ~ ., data = data.df)
     train.mtx <- xgb.DMatrix(data = train.sparse.tf, label = as.numeric(data.df$sold) - 1, missing = NA)
     set.seed(1234)
     mdl.xgb <- xgb.train(data = train.mtx, params = param, nrounds = 100)
     
     target <- c('sold')
     predictors <- setdiff(names(data.df), target)
     
     imp.var.mtx <- xgb.importance(predictors, model = mdl.xgb)
     xgb.plot.importance(imp.var.mtx)
     
     # Removing unnecessary features by using CV
     acc.total2 <- c()
     iterators2 <- seq(0.000, 0.020, by = 0.002)
     for (i in iterators2) {
          col.remove <- subset(imp.var.mtx, imp.var.mtx$Gain < i)$Feature
          train.cv.prned <- data.df[,!(names(data.df) %in% col.remove)]
          acc.total2 <- c(acc.total2, cv.kfold(train.cv.prned))
     }
     result.prund <- cbind(iterators2, acc.total2)
     result.df2 <- result.prund[order(-result.prund[, "acc.total2"]),] 
     print(result.df2)
     best.num2 <- result.df2[1,1]
     print(paste("Best threshold for Var Imp :",best.num2))
     
#      col.remove <- subset(imp.var.mtx, imp.var.mtx$Gain < best.num2)$Feature
#      data.df <- data.df[,!(names(data.df) %in% col.remove)]
#      target <- "sold"
#      col.keep <- names(data.df)[names(data.df) != target]
#      return(col.keep)
}

df.visu <- function (data.df) {
     target <- c('sold')
     predictors <- setdiff(names(data.df), target)
     
     # Feature Plot (sclaed, normalized)
     featurePlot(data.df[,predictors], data.df$sold, "strip")
     
     # Correlation Plot (highly correlated features are removed)
     corrplot.mixed(cor(data.df[,predictors]), 
                    lower = "circle", upper = "color",
                    tl.pos = "lt", diag = "n", order = "hclust",
                    hclust.method = "complete")
     
     # tSNE plot (clustering field should be well classified)
     # A tSNE (t-Distributed Stochastic Neighbor Embedding) is to reduce the multidimensional 2D.
     tsne = Rtsne(as.matrix(data.df[, predictors]), 
                  check_duplicates = FALSE, pca = FALSE, 
                  perplexity = 30, theta = 0.5, dims = 2)
     embedding = as.data.frame(tsne$Y)
     embedding$sold = data.df$sold
     s = ggplot(embedding, aes(x = V1, y = V2,color = sold)) +
          geom_point(size = 1.25) +
          guides(colour = guide_legend(override.aes = list(size = 6))) +
          xlab("") + ylab("") +
          ggtitle("2D Embedding of 'sold' Outcome") +
          theme_light(base_size = 20) +
          theme(axis.text.x = element_blank(),
                axis.text.y = element_blank())
     print(s)
}

cv.tuned <- function (data.df) {
     # data.df <- train
     # svm (gamma, cost)
     tuned.svm <- tune.svm(sold ~ ., data = data.df, gamma = 2^(-8:0), cost = 2^(0:8), probability = TRUE)
     
     
     # xgb boost cv (nrounds)
     training.sparse <- sparse.model.matrix(sold ~ ., data = data.df)
     training.mtx <- xgb.DMatrix(data = training.sparse, 
                                 label = as.numeric(data.df$sold)-1, missing=NA)
     params <- list(objective = "binary:logistic", nthread = 8)
     tuned.xgb <- xgb.cv(params = params, data = training.mtx, nrounds = 100, nfold = 30)
     nrounds.cv <- which(rowSums(tuned.xgb) == min(rowSums(tuned.xgb)))
     print(nrounds.cv)

          
     # xgb boost cv (max.depth, eta) 
     cv <- 5
     iterator1 <- seq(.1, 1, by = 0.1)
     iterator2 <- seq(1, 20, by = 2)
     acc.xgb.total <- c()
     acc.cv.total <- c()
     cv.summary <- c()
     for (k in iterator1) {
          for (j in iterator2) {
               for (i in 1:cv) {
                    print(paste('cv',i))
                    idx <- (((i-1) * round((1/cv)*nrow(data.df))) + 1):((i*round((1/cv) * nrow(data.df))))
                    training <- data.df[-idx,]
                    testing <- data.df[idx,]
                    
                    # Data into matrix
                    training.sparse <- sparse.model.matrix(sold ~ ., data = training)
                    training.mtx <- xgb.DMatrix(data = training.sparse, 
                                                label = as.numeric(training$sold) - 1, missing = NA)
                    testing.sparse <- sparse.model.matrix(sold ~ ., data = testing)
                    testing.mtx <- xgb.DMatrix(data = testing.sparse)
                    
                    mdl.xgb.cv <- xgboost(data = training.mtx, objective = "binary:logistic", 
                                       nthread = 8, verbose = 0, nround = nrounds.cv,
                                       eta = k, max.depth = j)
                    pred.xgb.cv <- predict(mdl.xgb.cv, testing.mtx)
                    pred.xgb.cv <- prediction(pred.xgb.cv,cv, testing$sold)
                    acc.xgb <- as.numeric(performance(pred.xgb.cv, "auc")@y.values)
                    acc.xgb.total <- c(acc.xgb.total, acc.xgb)
               }
               acc.cv.total <- c(acc.cv.total, mean(acc.xgb.total))
               temp <- data.frame(eta = k, max.depth = j, acc.cv.total = mean(acc.cv.total))
               cv.summary <- rbind(cv.summary, temp)
          }
     }
     best.idx = which(cv.summary$acc.cv.total == max(cv.summary[,'acc.cv.total']))
     cv.summary[best.idx,]
     
     
     # glmnet cv (alpha) 
     cv = 5
     iterator3 <- seq(.1, 1, by = .1)
     acc.glmn.total <- c()
     for (j in iterator3) {
          for (i in 1:cv) {
               print(paste('cv',i))
               idx <- (((i-1) * round((1/cv)*nrow(data.df))) + 1):((i*round((1/cv) * nrow(data.df))))
               training <- data.df[-idx,]
               testing <- data.df[idx,]
     
               train2 = training; test2 = testing
               train2$sold = NULL; test2$sold = NULL
               x = as.matrix(train2)

               mdl.glmn.cv <- cv.glmnet(x, y = training$sold, alpha = j, family = 'binomial',
                                        nfolds = 10, type.measure="auc")
               pred.glmn.cv <- predict(mdl.glmn.cv, as.matrix(test2), type = "response", s = mdl.glmn.cv$lambda.min)
               pred.glmn.cv <- prediction(pred.glmn.cv[,1], testing$sold)
               acc.glmn <- as.numeric(performance(pred.glmn.cv, "auc")@y.values)
          }
          acc.glmn.total <- c(acc.glmn.total, mean(acc.glmn))
     }
     glm.cv.df <- data.frame(i = iterator3, auc = acc.glmn.total)
     glm.cv.df <- glm.cv.df[order(-glm.cv.df[, "auc"]),] 
     glm.cv.df
}


# pre.proc.obj <- preProcess(full, method = c("pca") , pcaComp = 96)
# pca.df <- predict(pre.proc.obj, full)
# fullT <- cbind(full, pca.df)

# Extract train
# train <- head(fullT, nrow(eBayTrain))
train <- head(full, nrow(eBayTrain))
test <- head(full, nrow(eBayTest))
train$sold <- factor(sold)

cv.kfold.prob(train)
cv.kfold.class(train)
cv.pca.nz(cor.nz, full)
cv.pca.full(full)
cv.feat(train)
cv.varImp(train)
df.visu(train)
cv.tuned(train)
bagging(train)


###############################################################################################
# checking missing vars.
###############################################################################################
data.frame(sapply(full, function(x) return(paste0(round(sum(is.na(x))/length(x), 4)*100,'%'))))


###############################################################################################
# Loading Saved Data
###############################################################################################
# write.csv(full, "selc_pca.csv", row.names=FALSE)
full <- read.csv("selc_pca.csv")

