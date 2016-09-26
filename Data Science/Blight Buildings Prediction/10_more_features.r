library(tree, quietly=TRUE)
library(rpart, quietly=TRUE)
library(party, quietly=TRUE)
library(randomForest, quietly=TRUE)


callcount <- calls %>% 
   select(building,incident) %>% 
   group_by(building) %>% 
   summarise(callcount=n())
callcount <- callcount %>% arrange(desc(callcount))
callcount %>% head(20)

crimecount <- crimes %>% 
   select(building,incident) %>% 
   group_by(building) %>% 
   summarise(crimecount=n())
crimecount <- crimecount %>% arrange(desc(crimecount))
crimecount %>% head(20)


modeldata <- modeldata %>% 
             left_join(callcount,by=c("building")) %>% 
             mutate_each(funs(replace(., which(is.na(.)), 0))) %>%
             data.frame
modeldata <- modeldata %>% 
             left_join(crimecount,by=c("building")) %>% 
             mutate_each(funs(replace(., which(is.na(.)), 0))) %>%
             data.frame
modeldata %>% str

write.csv(modeldata, file="data/modeldata.csv", row.names = FALSE)
test  <- modeldata %>% filter(modeldata$group==1)
train <- modeldata %>% filter(modeldata$group!=1)



f1a <- formula(label~count)
f1b <- formula(label~callcount)  # poor predictor
f1c <- formula(label~crimecount) # poor predictor
f2a <- formula(label~count+callcount)
f2b <- formula(label~count+crimecount)
f3a <- formula(label~count+callcount+crimecount)

tic()
t(sapply(1:5,function(x)crossvalidate.lm(f1a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.lm(f1b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.lm(f1c,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.lm(f2a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.lm(f2b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.lm(f3a,x))) %>% colMeans
toc()
#[1] 17.071

tic()
t(sapply(1:5,function(x)crossvalidate.glm(f1a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.glm(f1b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.glm(f1c,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.glm(f2a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.glm(f2b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.glm(f3a,x))) %>% colMeans
toc()
#[1] 19.934

tic()
t(sapply(1:5,function(x)crossvalidate.trm(f1a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.trm(f1b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.trm(f1c,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.trm(f2a,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.trm(f2b,x))) %>% colMeans
t(sapply(1:5,function(x)crossvalidate.trm(f3a,x))) %>% colMeans
toc()
#[1] 13.756


f1a <- formula(factor~count)
f1b <- formula(factor~callcount)  # poor predictor
f1c <- formula(factor~crimecount) # poor predictor
f2a <- formula(factor~count+callcount)
f2b <- formula(factor~count+crimecount)
f3a <- formula(factor~count+callcount+crimecount)

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.tree(f1a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(f1b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(f1c,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(f2a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(f2b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.tree(f3a,x)) %>% mean
toc()


set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.rpart(f1a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(f1b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(f1c,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(f2a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(f2b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rpart(f3a,x)) %>% mean
toc()
#[1] 2.056

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.ctree(f1a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(f1b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(f1c,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(f2a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(f2b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.ctree(f3a,x)) %>% mean
toc()
#[1] 3.263

set.seed(817)
tic()
sapply(1:5,function(x)crossvalidate.rf(f1a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(f1b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(f1c,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(f2a,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(f2b,x)) %>% mean
sapply(1:5,function(x)crossvalidate.rf(f3a,x)) %>% mean
toc()
#[1] 65.829

