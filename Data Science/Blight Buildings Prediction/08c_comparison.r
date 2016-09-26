
set.seed(817)
accuracyVALUE <- function(label,predicted) length(label[label==predicted])/length(label)


########################################### simple decision tree

# if target is factorized, then prediction results in a matrix of probabilities for each level

library(tree)
tm <- function(f,data,s=10){ct=tree.control(nrow(data),mindev=0,minsize=s); tree(f,data,control=ct)}
# mindev=0 => splitting runs forever
# minsize=10 splitting stops at nodes with 10 observations


treeMODEL <- tm(label~count,train)
summary(treeMODEL)
treePRED <- predict(treeMODEL,test)
accuracyVEC(test$label,treePRED,0.5)

crossvalidate.trm <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- tree(formula,train,control=tree.control(nrow(train),mindev=0,minsize=2))
   PRED  <- predict(MODEL,test)
   roc(test$label,PRED)
}   

crossvalidate.tree <- function(formula,g=1,data=modeldata){
   test    <- data %>% filter(group==g) %>% select(-group)
   train   <- data %>% filter(group!=g) %>% select(-group)
   MODEL <- tree(formula,train,control=tree.control(nrow(train),mindev=0,minsize=2))
   PRED  <- predict(MODEL,test,type ="class")
   accuracyVALUE(test$label,PRED)
}   
sapply(1:5,function(x)crossvalidate.tree(factor~count,x))%>% mean
#[1] 0.7593523

falsepositives = sapply(limits,FUN=function(x)accuracyVEC(test$label,treePRED,x)[[4]])
truepositives  = sapply(limits,FUN=function(x)accuracyVEC(test$label,treePRED,x)[[2]])
falsepositiveRATE = falsepositives / max(falsepositives)
truepositiveRATE  = truepositives / max(truepositives)
plot(truepositiveRATE ~ falsepositiveRATE)

##################### compare linear and logistic regression

par(bg='white')
plot(label ~ count,data=test,type="n",ylab="probability ")
o=order(test$count)
lines(lmPRED[o] ~ test$count[o],col="red")
lines(glmPRED[o] ~ test$count[o],col="blue")
lines(treePRED[o] ~ test$count[o],col="green")
legend("topleft",y=NULL,xpd=TRUE,bty="n",
                      c("p(label=1) linear model with threshold",
                        "p(label=1) logistic regression",
                        "p(label=1) decicion tree",
                        "observed freq(label=1)",
                        "observed freq(label=0)"),
                      col=c("red","blue","green","black","black"),lty=c(1,1,1,1,2))

hist0 <- hist(test$count[test$label==0],plot=FALSE)
hist1 <- hist(test$count[test$label==1],plot=FALSE)
points(c(0,hist0$density,0) ~ c(0,hist0$breaks),lty=2,type="s")
points(c(0,hist1$density,0) ~ c(0,hist1$breaks),type="s")

dev.print(device=png,filename ="maps/comparison.png",width=150,height=150,units="mm", res=300, type = "cairo")


