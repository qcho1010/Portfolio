# caret

#packageurl <- "https://cran.r-project.org/src/contrib/Archive/pbkrtest/pbkrtest_0.4-4.tar.gz" 
#install.packages(packageurl, repos=NULL, type="source")
#install.packages("caret")


require(dplyr)

mm<-data.frame(violationsR$building,
               model.matrix(~violationsR$PaymentStatus+0),
               model.matrix(~violationsR$Disposition + 0),
               stringsAsFactors = FALSE)
               
colnames(mm)<-make.names(c("building",
                           levels(as.factor(violationsR$PaymentStatus)),
                           levels(as.factor(violationsR$Disposition))))


one_hot <- mm %>% group_by(building) %>% summarize_each(funs(max))
write.csv(one_hot, file="data/one_hot.csv", row.names = FALSE)


##############################################################
# column vector otherspart and all amounts expcept judgment amount should be dropped!

modeldataOHE <- modeldata %>% 
             select(building,ID,label,factor,group) %>%
             left_join(one_hot,by=c("building")) %>% 
             mutate_each(funs(replace(., which(is.na(.)), 0)))

modeldataALL <- modeldata %>% 
             select(-lon,-lat) %>%
             select(building,ID,label,factor,group,everything()) %>%
             left_join(one_hot,by=c("building")) %>% 
             mutate_each(funs(replace(., which(is.na(.)), 0)))
            
factorOHE <- modeldataOHE %>% select(-building,-ID,-label)
factorALL <- modeldataALL %>% select(-building,-ID,-label)

write.csv(modeldataOHE, file="data/modeldataOHE.csv", row.names = FALSE)
write.csv(modeldataALL, file="data/modeldataALL.csv", row.names = FALSE)
write.csv(factorOHE, file="data/factorOHE.csv", row.names = FALSE)
write.csv(factorALL, file="data/factorALL.csv", row.names = FALSE)

#####################################################################################################################################


require(tree, quietly=TRUE)
require(rpart, quietly=TRUE)
require(party, quietly=TRUE)
require(randomForest, quietly=TRUE)
require(e1071, quietly=TRUE)
require(xgboost, quietly=TRUE)

tic();sapply(1:5,function(x)crossvalidate.glm(factor~.,x,factorOHE)[1]) %>% mean
toc()
#[1] 0.7603191
#[1] 6.257
tic();sapply(1:5,function(x)crossvalidate.rpart(factor~.,x,factorOHE)) %>% mean
toc()
#[1] 0.7596168
#[1] 1.984
tic();sapply(1:5,function(x)crossvalidate.ctree(factor~.,x,factorOHE)) %>% mean
toc()
#[1] 0.7603191
#[1] 1.318
tic();sapply(1:5,function(x)crossvalidate.rf(factor~.,x,factorOHE)) %>% mean
toc()
#[1] 0.5948021
#[1] 34.225
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorOHE,'linear')) %>% mean
toc()
#[1] 0.7578168
#[1] 29.506
tic();sapply(1:5,function(x)crossvalidate.xgboost(factor~.,x,factorOHE)) %>% mean
toc()
#[1] 0.7562388
#[1] 1.137

tic();sapply(1:5,function(x)crossvalidate.glm(factor~.,x,factorALL)[1]) %>% mean
toc()
tic();sapply(1:5,function(x)crossvalidate.rpart(factor~.,x,factorALL)) %>% mean
toc()
tic();sapply(1:5,function(x)crossvalidate.ctree(factor~.,x,factorALL)) %>% mean
toc()
tic();sapply(1:5,function(x)crossvalidate.rf(factor~.,x,factorALL)) %>% mean
toc()
tic();sapply(1:5,function(x)crossvalidate.svm(factor~.,x,factorALL,'linear')) %>% mean
toc()
tic();sapply(1:5,function(x)crossvalidate.xgboost(factor~.,x,factorALL)) %>% mean
toc()


#########################################################################

set.seed(817)


#no need fro cross validation in random forests!!!
g<-1
data <- factorALL
test    <- data %>% filter(group==g) %>% select(-group)
train   <- data %>% filter(group!=g) %>% select(-group)
MODEL <- randomForest::randomForest(factor~., data=train,ntree=100,importance=TRUE)
randomForest::importance(MODEL, type = 1)
print(MODEL)

imp <- as.data.frame(randomForest::importance(MODEL, type = 1))
imp$feature <- rownames(imp)
imp %>% arrange(desc(MeanDecreaseAccuracy))

par(bg='white')
randomForest::varImpPlot(MODEL)
dev.print(device=png,filename ="maps/importance.png",width=300,units="mm", res=300, type = "cairo")

PRED <- predict(MODEL,test, type="response")
accuracyVALUE(test$factor,PRED)
