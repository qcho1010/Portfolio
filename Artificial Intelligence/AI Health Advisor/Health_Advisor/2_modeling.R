library(mlr)
library(caret)
library(xgboost)

setwd("~/Documents/archHack")
canc_data <- read.csv("Health_Advisor/data/canc_data.csv")
heart_data <- read.csv("Health_Advisor/data/heart_data.csv")

# split data
intrain <- createDataPartition(canc_data$risk_rate, p=0.7, list=FALSE)
canc_train <- canc_data[intrain, ]
canc_test <- canc_data[-intrain, ]
intrain <- createDataPartition(heart_data$risk_rate, p=0.7, list=FALSE)
heart_train <- heart_data[intrain, ]
heart_test <- heart_data[-intrain, ]

# create task
canc_train_task <- makeRegrTask(data=canc_train, target="risk_rate")
canc_test_task <- makeRegrTask(data=canc_test, target="risk_rate")
heart_train_task <- makeRegrTask(data=heart_train, target="risk_rate")
heart_test_task <- makeRegrTask(data=heart_test, target="risk_rate")

# xgboost
# set.seed(2016)
xgb_learner <- makeLearner("regr.xgboost", predict.type="response")
xgb_learner$par.vals <- list(
  objective = "binary:logistic",
  eval_metric = "error",
  nrounds = 150,
  print.every.n = 150
)

# define hyperparameters for tuning
xg_ps <- makeParamSet( 
  makeIntegerParam("max_depth",lower=5,upper=15),
  makeNumericParam("lambda",lower=0.05,upper=0.5),
  makeNumericParam("eta", lower = 0.01, upper = 0.5),
  makeNumericParam("subsample", lower = 0.50, upper = 1),
  makeNumericParam("min_child_weight",lower=2,upper=10),
  makeNumericParam("colsample_bytree",lower = 0.50,upper = 0.80)
)

#define search function
rancontrol <- makeTuneControlRandom(maxit = 5L) #do 5 iterations

# 5 fold cross validation
set_cv <- makeResampleDesc("CV", iters=5L)



########################### Cancer ########################### 
# tune parameters
xgb_tune <- tuneParams(learner=xgb_learner, task=canc_train_task, 
                       resampling=set_cv, par.set=xg_ps, control=rancontrol)
# Tune result:
# [Tune] Result: max_depth=5; lambda=0.329; eta=0.357; subsample=0.842; min_child_weight=8.57; colsample_bytree=0.613 : mse.test.mean=0.000631

# set optimal parameters
xgb_new <- setHyperPars(learner=xgb_learner, par.vals=xgb_tune$x)

# train model
canc_xgmodel <- train(xgb_new, canc_train_task)

# make prediction
canc_predict.xg <- predict(canc_xgmodel, canc_test_task)$data$response

# evaluation
sqrt(mean((canc_test$risk_rate-canc_predict.xg)^2))
# RMS = 0.0245341


########################### Heart Disease ########################### 
# tune parameters
xgb_tune <- tuneParams(learner=xgb_learner, task=heart_train_task, 
                       resampling=set_cv, par.set=xg_ps, control=rancontrol)
# Tune result:
# Result: max_depth=9; lambda=0.481; eta=0.0771; subsample=0.611; min_child_weight=8.46; colsample_bytree=0.739 : mse.test.mean=0.000327

# set optimal parameters
xgb_new <- setHyperPars(learner=xgb_learner, par.vals=xgb_tune$x)

# train model
heart_xgmodel <- train(xgb_new, heart_train_task)

# make prediction
heart_predict.xg <- predict(heart_xgmodel, heart_test_task)$data$response

# evaluation
sqrt(mean((heart_test$risk_rate-canc_predict.xg)^2))
# RMSE = 0.2188088

########################### Save  ########################### 
saveRDS(canc_xgmodel, file="Health_Advisor/data/model_canc.rds")
saveRDS(heart_xgmodel, file="Health_Advisor/data/model_heart.rds")
