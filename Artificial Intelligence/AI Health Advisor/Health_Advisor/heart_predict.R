# load models
# setwd("~/Documents/archHack/Health_Advisor")
library(mlr)

pre_heart <- readRDS("./data/pre_heart.rds")
model_heart <-readRDS("./data/model_heart.rds")

# Load heart graphs
g_heart_cholesterol <-readRDS("./data/graph/g_heart_cholesterol.rds")
g_heart_blood_press <-readRDS("./data/graph/g_heart_blood_press.rds")
g_heart_sodium <-readRDS("./data/graph/g_heart_sodium.rds")
g_heart_age <-readRDS("./data/graph/g_heart_age.rds")
g_heart_alcohol <-readRDS("./data/graph/g_heart_alcohol.rds")
g_heart_calories <-readRDS("./data/graph/g_heart_calories.rds")
g_heart_cigarette <-readRDS("./data/graph/g_heart_cigarette.rds")
g_heart_exercise <-readRDS("./data/graph/g_heart_exercise.rds")
g_heart_grain <-readRDS("./data/graph/g_heart_grain.rds")
g_heart_meat <-readRDS("./data/graph/g_heart_meat.rds")
g_heart_risk_rate <-readRDS("./data/graph/g_heart_risk_rate.rds")
g_heart_stress <-readRDS("./data/graph/g_heart_stress.rds")
g_heart_sugar <-readRDS("./data/graph/g_heart_sugar.rds")
g_heart_vegetable <-readRDS("./data/graph/g_heart_vegetable.rds")
g_heart_alcohol <-readRDS("./data/graph/g_heart_alcohol.rds")

prediction2 <- function(inputs) {
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
    alcohol=as.numeric(inputs[11]), sugar=as.numeric(inputs[12]),
    cholesterol=as.numeric(inputs[13]), blood_press=as.numeric(inputs[14]),
    sodium=as.numeric(inputs[15]))
  
  # cholesterol, blood_press, sodium
  
  # predict futures outcomes as well until 100 years old
  risk_rate <- c()
  ages <- c()
  for (i in seq(0, 80-inputs$age)) {
    # scale, normalize
    inputs$age <- inputs$age + 1
    pre_inputs <- predict(pre_heart, inputs)
  
    # create empty target variable
    pre_inputs$risk_rate <- 0
    heart_test_task <- makeRegrTask(id="risk_rate", pre_inputs, target="risk_rate")
    pred <- predict(model_heart, heart_test_task)$data$response
    pred <- round(pred * 100, 2)  
    risk_rate <- rbind(risk_rate, pred)
    ages <- rbind(ages, inputs$age)
    
  }
  df <- as.data.frame(cbind(ages, risk_rate))
  colnames(df) <- c("age", "risk_rate")
  return(df)
}
