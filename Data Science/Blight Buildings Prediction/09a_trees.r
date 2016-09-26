#~ http://www.r-bloggers.com/a-brief-tour-of-the-trees-and-forests/
# see below

require(tree, quietly=TRUE)
require(rpart, quietly=TRUE)
require(party, quietly=TRUE)
require(randomForest, quietly=TRUE)

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.tree(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 5.695


require(rpart, quietly=TRUE)
rpartMODEL <- rpart(label ~ count, data=train,method="class",control=rpart.control(minbucket=20,cp=0.000001))
rpartPRED  <- predict(rpartMODEL,newdata=test, type="prob")[,2]
rpartPREDL <- predict(rpartMODEL,newdata=test, type="class")

accuracyVALUE(test$label,rpartPREDL)
#[1] 0.7769646

print(rpartMODEL)
printcp(rpartMODEL)

limits=100:0/100
accuracies     = sapply(limits,FUN=function(x)accuracyVEC(test$label,rpartPRED,x)[[6]])
falsepositives = sapply(limits,FUN=function(x)accuracyVEC(test$label,rpartPRED,x)[[4]])
truepositives  = sapply(limits,FUN=function(x)accuracyVEC(test$label,rpartPRED,x)[[2]])
plot (accuracies ~ limits)
plot (truepositives ~ falsepositives)

#find threshold with maximum accuracy:
limits[which.max(accuracies)]
#[1] 0.46
accuracies[which.max(accuracies)]
#[1] 0.7798668

crossvalidate.rpart <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- rpart(formula, data=train,method="class",control=rpart.control(minbucket=20,cp=0.000001))
   PRED  <- predict(MODEL,test,type="class")
   accuracyVALUE(test$factor,PRED)
}   

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.rpart(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(label~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(label~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(fml_full,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(fml_fullc,x)) %>% mean
toc()
#[1] 4.282


ctreeMODEL <- ctree(factor ~ count, data=train)
              #controls=ctree_control(minbucket=20,cp=0.000001))
ctreePRED  <- predict(ctreeMODEL,test,type="response")

print(ctreeMODEL)
limits=0:100/100
accuracies     = sapply(limits,FUN=function(x)accuracyVEC(test$label,ctreePRED,x)[[6]])
falsepositives = sapply(limits,FUN=function(x)accuracyVEC(test$label,ctreePRED,x)[[4]])
truepositives  = sapply(limits,FUN=function(x)accuracyVEC(test$label,ctreePRED,x)[[2]])
plot (accuracies ~ limits)
plot (truepositives ~ falsepositives)

#find threshold with maximum accuracy:
limits[which.max(accuracies)]
#[1] 0.51
accuracies[which.max(accuracies)]
#[1] 0.7798668

crossvalidate.ctree <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- ctree(formula, data=train)
   PRED  <- predict(MODEL,test,type="response")
   accuracyVALUE(test$factor,PRED)
}   
set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.ctree(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 4.098


require(randomForest, quietly=TRUE)
rfMODEL <- randomForest::randomForest(factor ~ count, data=train,
      ntree=500,
      mtry=1,
      importance=TRUE,
      na.action=randomForest::na.roughfix,
      replace=FALSE)
rfPRED <- predict(rfMODEL,test, type="response")
print(rfMODEL)


limits=0:100/100
accuracies     = sapply(limits,FUN=function(x)accuracyVEC(test$label,rfPRED,x)[[6]])
falsepositives = sapply(limits,FUN=function(x)accuracyVEC(test$label,rfPRED,x)[[4]])
truepositives  = sapply(limits,FUN=function(x)accuracyVEC(test$label,rfPRED,x)[[2]])
plot (accuracies ~ limits)
plot (truepositives ~ falsepositives)

#find threshold with maximum accuracy:
limits[which.max(accuracies)]
#[1] 0.52
accuracies[which.max(accuracies)]
#[1] 0.7837838


crossvalidate.rf <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- randomForest::randomForest(formula, data=train,
      ntree=500,
      mtry=1,
      importance=TRUE,
      na.action=randomForest::na.roughfix,
      replace=FALSE)
   PRED <- predict(MODEL,test, type="response")
   accuracyVALUE(test$factor,PRED)
}

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.rf(factor~count,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(factor~graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(factor~count+graffiti+defective+otherspart,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(factor~graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(factor~count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others,x)) %>% mean
toc()
#[1] 81.282
# The `pROC' package implements various AUC functions
require(pROC)
# Calculate the Area Under the Curve (AUC):
pROC::roc(label ~ as.double(as.character(rfPRED)), data=test)
# Calculate the AUC Confidence Interval:
pROC::ci.auc(label ~ as.double(as.character(rfPRED)), data=test)
# List the importance of the variables.
#rn <- round(randomForest::importance(rfMODEL), 2)
#rn[order(rn, decreasing=TRUE)]

