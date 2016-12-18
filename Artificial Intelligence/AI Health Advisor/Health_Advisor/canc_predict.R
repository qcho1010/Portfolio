# load models
# setwd("~/Documents/archHack/Health_Advisor")
library(mlr)

pre_canc <- readRDS("./data/pre_canc.rds")
model_canc <- readRDS("./data/model_canc.rds")

# Load cancer graphs
g_canc_age <-readRDS("./data/graph/g_canc_age.rds")
g_canc_alcohol <-readRDS("./data/graph/g_canc_alcohol.rds")
g_canc_calories <-readRDS("./data/graph/g_canc_calories.rds")
g_canc_cigarette <-readRDS("./data/graph/g_canc_cigarette.rds")
g_canc_exercise <-readRDS("./data/graph/g_canc_exercise.rds")
g_canc_grain <-readRDS("./data/graph/g_canc_grain.rds")
g_canc_meat <-readRDS("./data/graph/g_canc_meat.rds")
g_canc_risk_rate <-readRDS("./data/graph/g_canc_risk_rate.rds")
g_canc_stress <-readRDS("./data/graph/g_canc_stress.rds")
g_canc_sugar <-readRDS("./data/graph/g_canc_sugar.rds")
g_canc_vegetable <-readRDS("./data/graph/g_canc_vegetable.rds")
g_canc_alcohol <-readRDS("./data/graph/g_canc_alcohol.rds")


prediction <- function(inputs) {
  # clean input
  inputs[1] <- ifelse(inputs[1] == "a", 1, 0)
  inputs[1] <- ifelse(inputs[1] == "a", 1, 0)
  inputs[2] <- ifelse(inputs[2] == "a", 1, 0)
  inputs[2] <- ifelse(inputs[2] == "a", 1, 0)
  
  # convert it to dataframe
  inputs <- data.frame(
    family_hist=as.numeric(inputs[1]), male=as.numeric(inputs[2]),
      age=as.numeric(inputs[3]), cigarette=as.numeric(inputs[4]),
      exercise=as.numeric(inputs[5]), stress=as.numeric(inputs[6]),
      grain=as.numeric(inputs[7]), vegetable=as.numeric(inputs[8]),
      meat=as.numeric(inputs[9]), calories=as.numeric(inputs[10]),
      alcohol=as.numeric(inputs[11]), sugar=as.numeric(inputs[12]))
  
  # predict futures outcomes as well until 100 years old
  risk_rate <- c()
  ages <- c()
  for (i in seq(0, 80-inputs$age)) {
    # scale, normalize
    inputs$age <- inputs$age + 1
    pre_inputs <- predict(pre_canc, inputs)
  
    # create empty target variable
    pre_inputs$risk_rate <- 0
    canc_test_task <- makeRegrTask(id="risk_rate", pre_inputs, target="risk_rate")
    pred <- predict(model_canc, canc_test_task)$data$response
    pred <- round(pred * 100, 2)  
    risk_rate <- rbind(risk_rate, pred)
    ages <- rbind(ages, inputs$age)
    
  }
  df <- as.data.frame(cbind(ages, risk_rate))
  colnames(df) <- c("age", "risk_rate")
  return(df)
}
