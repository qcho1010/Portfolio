
require(e1071, quietly=TRUE) 
# svm
# formula is not very useful for many columns
# needs tuning!

test    <- modeldataOHE %>% filter(group==1)
train   <- modeldataOHE %>% filter(group!=1)
trainx  <- train %>% select(-building,-ID,-label,-factor,-group)
testx   <- test  %>% select(-building,-ID,-label,-factor,-group)
trainf  <- train %>% select(-building,-ID,-label,-group)
testf   <- test  %>% select(-building,-ID,-label,-group)

tic()
MODEL <- svm(x=trainx,y=train$factor,kernel="linear")
PRED  <- predict(MODEL,testx)
toc();
#[1] 4.745

tic()
MODEL <- svm(factor ~ label*0+building*0+ID*0+group*0+.,data=train,kernel="linear")
PRED  <- predict(MODEL,test)
toc();
#[1] 20.909

tic()
MODELF <- svm(factor ~ .,data=trainf,kernel="linear")
PREDF  <- predict(MODELF,testf)
toc();
#[1] 4.783


crossvalidate.svm <- function(formula,g=1,data=modeldata,k='linear'){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- svm(formula,data=train,kernel=k)
   PRED  <- predict(MODEL,test)
   accuracyVALUE(test$factor,PRED)
}

 
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorOHE,'linear')) %>% mean
toc()
#[1] 0.7578168
#[1] 23.203
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorOHE,'polynomial')) %>% mean
#[1] 0.6737048
#[1] 37.665
toc()
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorOHE,'radial')) %>% mean
toc()
#[1] 0.7602396
#[1] 53.046
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorOHE,'sigmoid')) %>% mean
toc()
#[1] 0.7578168
#[1] 52.266
