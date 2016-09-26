library(ada, quietly=TRUE)
#formula is not propagated to trees
#https://github.com/cran/ada/blob/master/R/ada.formula.R
#nine years old!!!


adaformula <- function(formula, data,...,subset,na.action=na.rpart){
  m <- model.frame(formula,data)
  Terms = attr(m, "terms")
  target <- names(m)[1]
  y = as.vector(model.extract(m,"response"))
  preds<-attr(attributes(m)$terms,"term.labels")
  x<-m
  attr(x,"terms")<-NULL
  x[target] <- NULL
  res = ada.default(x,y,...,na.action=na.action)
  res$terms = Terms
  cl = match.call()
  cl[[1]] = as.name("ada")
  res$call = cl
  res$names = preds
  res
}


crossvalidate.ada <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- adaformula(formula, data=train,iter = 50, 
      control = rpart::rpart.control(maxdepth = 30,cp = 0.01, minsplit = 20, xval = 10))
      randomForest::randomForest(formula, data=train,
      ntree=500,
      mtry=1,
      importance=TRUE,
      na.action=randomForest::na.roughfix,
      replace=FALSE)
   PRED <- predict(MODEL,test, type="vector")
   accuracyVALUE(test$factor,PRED)
}

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.ada(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ada(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ada(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ada(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ada(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 289.197

library(adabag)
# bootstrapping by default

crossvalidate.boost <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL<-boosting(formula,data=train, boos=FALSE, mfinal=20,coeflearn='Breiman')
   PRED <- predict(MODEL,test, type="vector")
   accuracyVALUE(test$factor,as.double(PRED$class))
}

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.boost(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.boost(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.boost(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.boost(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.boost(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 156.528

library(mboost)
# https://cran.r-project.org/web/packages/mboost/index.html
# for linear models
# mboost baselearner = "btree"
# glmboost


library(xgboost)
# xgb.DMatrix instead of formula
# https://cran.r-project.org/web/packages/xgboost/index.html
# http://www.r-bloggers.com/an-introduction-to-xgboost-r-package/

crossvalidate.xgboost <- function(formula,g=1,data=modeldata){
  test    <- data %>% filter(group==g) %>% select(-group)
  train   <- data %>% filter(group!=g) %>% select(-group)
  mftrain <- model.frame(formula,train)
  target  <- names(mftrain)[1]
  xtrain  <- mftrain
  attr(xtrain,"terms")<-NULL
  xtrain[target] <- NULL
  mftest  <- model.frame(formula,test)
  target  <- names(mftest)[1]
  xtest   <- mftest
  attr(xtest,"terms")<-NULL
  xtest[target] <- NULL

  mtrain <- as.matrix(xtrain)
  mtest <- as.matrix(xtest)
  MODEL <- xgboost(data = mtrain,label = as.double(as.character(train$factor)), max.depth = 30, eta = 0.1,nround = 20, objective = "binary:logistic",verbose=0)
  PROB <- predict(MODEL, mtest)
  accuracyVEC(test$factor,PROB,0.5)$accuracy
}
crossvalidate.xgo(factor~count,1)
set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.xgboost(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.xgboost(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.xgboost(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.xgboost(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.xgboost(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 8.388
