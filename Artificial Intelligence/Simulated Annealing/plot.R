library(ggplot2)

setwd("E:/Google Drive/Class/4342/proj2")
data1 <- read.csv("SAresult1.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="SAresult1.png")

data1 <- read.csv("SAresult2.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="SAresult2.png")


data1 <- read.csv("SAresult3.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="SAresult3.png")


data1 <- read.csv("SAresult4.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="SAresult4.png")


data1 <- read.csv("SAresult5.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="SAresult5.png")

