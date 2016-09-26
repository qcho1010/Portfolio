#################### model with keywords:

modeldata <- modeldata%>%mutate(otherspart=debris+waste+vehicle+rodents+maintenance+others)
train <- train%>%mutate(otherspart=debris+waste+vehicle+rodents+maintenance+others)
test <- test%>%mutate(otherspart=debris+waste+vehicle+rodents+maintenance+others)
fml_part <-  formula(label ~        graffiti+defective+othersspart)
fml_full <-  formula(label ~        graffiti+defective+debris+waste+vehicle+rodents+maintenance+others)
fml_fullc <- formula(label ~  count+graffiti+defective+debris+waste+vehicle+rodents+maintenance+others)


summary(lm(label~count,data=train))
summary(lm(label~graffiti+defective+otherspart,data=train))
summary(lm(label~count+graffiti+defective+otherspart,data=train))
summary(lm(fml_full,data=train))
summary(lm(fml_fullc,data=train))

data.frame(t(sapply(1:5,function(x)crossvalidate.lm(label~count,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.lm(label~graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.lm(label~count+graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.lm(fml_full,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.lm(fml_fullc,x)))) %>% colMeans

data.frame(t(sapply(1:5,function(x)crossvalidate.glm(label~count,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.glm(label~graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.glm(label~count+graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.glm(fml_full,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.glm(fml_fullc,x)))) %>% colMeans

data.frame(t(sapply(1:5,function(x)crossvalidate.trm(label~count,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.trm(label~graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.trm(label~count+graffiti+defective+otherspart,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.trm(fml_full,x)))) %>% colMeans
data.frame(t(sapply(1:5,function(x)crossvalidate.trm(fml_fullc,x)))) %>% colMeans

#################### baseline

test$random <- sample.int(2, length(test$label), replace=TRUE) -1
accuracyVEC(test$label,test$random,0.5)$accuracy
#[1] 0.4953648  => CORRECT	
