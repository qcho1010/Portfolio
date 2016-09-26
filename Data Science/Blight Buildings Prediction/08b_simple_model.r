

############### 5fold cross validation => five groups

modeldata$factor <- as.factor(modeldata$label)
set.seed(23)
modeldata$group  <- sample.int(5, length(modeldata$building), replace=TRUE)
test  <- modeldata %>% filter(modeldata$group==1)
train <- modeldata %>% filter(modeldata$group!=1)

nrow(modeldata)
#[1] 12710
nrow(train)
#~= [1] 10231
nrow(test)
#~= [1] 2481

#summary(modeldata$label)
#summary(modeldata$factor)
#summary(modeldata$bool)
#summary(train$label)
#summary(train$factor)
#summary(train$bool)
#summary(test$label)
#summary(test$factor)
#summary(test$bool)
# => this is distributed as expected


########################################### accuracy


accuracy <- function(threshold) accuracyVEC(test$label,test$predicted, threshold)

accuracyVEC <- function(label,predicted,threshold){
   positive <- predicted > threshold 
   negative <- predicted <=  threshold
   n=length(label)
   true1 =  sum(label==1 & positive, na.rm=TRUE)
   true0 =  sum(label==0 & negative, na.rm=TRUE)
   false1 = sum(label==0 & positive, na.rm=TRUE)
   false0 = sum(label==1 & negative, na.rm=TRUE)
   data.frame(threshold,
              true1,
              true0,
              false1,
              false0,
              accuracy=(true0+true1)/n)
}

accuracyEQ <- function(label,predicted){
   n=length(label)
   true =  sum(label==predicted, na.rm=TRUE)
   return (true/n)
}


########################################### linear regression
# predicts a continuous double float

#summary(predict(lm(label~count,data=train),test))
#summary(predict(lm(factor~count,data=train),test))
#summary(predict(lm(bool~count,data=train),test))
#summary(predict(lm(string~count,data=train),test))
#summary(predict(lm(label~count+0,data=train),test))

test  <- modeldata %>% filter(modeldata$group==1)
train <- modeldata %>% filter(modeldata$group!=1)
lmMODEL <- lm(label~count,data=train)
lmPRED  <- predict(lmMODEL,test)

# http://stackoverflow.com/a/30280873
rectangles <- function(y,x){diff(x) * (head(y,-1)+tail(y,-1))/2}

limits=100:0/100
accuracies     = sapply(limits,FUN=function(x)accuracyVEC(test$label,lmPRED,x)[[6]])
falsepositives = sapply(limits,FUN=function(x)accuracyVEC(test$label,lmPRED,x)[[4]])
truepositives  = sapply(limits,FUN=function(x)accuracyVEC(test$label,lmPRED,x)[[2]])
falsepositiveRATE = falsepositives / max(falsepositives)
truepositiveRATE  = truepositives / max(truepositives)

# Receiver operational characteristics ROC 
plot (accuracies ~ limits)
plot (truepositiveRATE ~ falsepositiveRATE)
#find threshold with maximum accuracy
maxacc     <- accuracies[which.max(accuracies)]
# threshold for max accuracy
limitatmax <- limits[which.max(accuracies)]
#Area under curve AUC
aoc <- sum(rectangles(truepositiveRATE,falsepositiveRATE))


#find threshold with maximum accuracy:
limits[which.max(accuracies)]
#[1] 0.58
accuracies[which.max(accuracies)]
#[1] 0.7514863

#Area under curve AUC
sum(rectangles(truepositiveRATE,falsepositiveRATE))
#[1] 0.7190062

# Receiver operational characteristics ROC 
roc <- function(label,pred)
{
   limits=100:0/100
   accuracies     = sapply(limits,FUN=function(x)accuracyVEC(label,pred,x)[[6]])
   falsepositives = sapply(limits,FUN=function(x)accuracyVEC(label,pred,x)[[4]])
   truepositives  = sapply(limits,FUN=function(x)accuracyVEC(label,pred,x)[[2]])
   falsepositiveRATE = falsepositives / max(falsepositives)
   truepositiveRATE  = truepositives / max(truepositives)
   #find threshold with maximum accuracy
   maxacc     <- accuracies[which.max(accuracies)]
   # threshold for max accuracy
   threshold <- limits[which.max(accuracies)]
   #Area under curve AUC
   aoc <- sum(rectangles(truepositiveRATE,falsepositiveRATE))
   r <- c(maxacc,threshold,aoc)
   names(r) <- c("maxacc","threshold","aoc")
   return(r)
}

######## cross validation


crossvalidate.lm <- function(formula,g,data=modeldata){
   test    <- data %>% filter(group==g)
   train   <- data %>% filter(group!=g)
   MODEL <- lm(formula,data=train)
   PRED  <- predict(MODEL,test)
   roc(test$label,PRED)
}   

t(sapply(1:5,function(x)crossvalidate.lm(label~count,x))) %>% colMeans
#   maxacc threshold       aoc 
#0.7603191 0.5900000 0.7277253 


########################################### logistic regression

glmMODEL <- glm(label~count,data=train,family="binomial")
glmPRED <- predict(glmMODEL,test,type="response")
roc(test$label,glmPRED)

crossvalidate.glm <- function(formula,g,data=modeldata){
   test    <- data %>% filter(group==g)
   train   <- data %>% filter(group!=g)
   MODEL <- glm(formula,data=train,family="binomial")
   PRED  <- predict(MODEL,test,type="response")
   roc(test$factor,PRED)
}   

crossvalidate.glm(label~count,1)
#   maxacc threshold       aoc 
#0.7573559 0.6000000 0.7270974 
crossvalidate.glm(factor~count,1)
#   maxacc threshold       aoc 
#0.7573559 0.6000000 0.7270974 

