library(ggplot2)

setwd("E:/Google Drive/Class/4342/proj1")
data1 <- read.csv("euclidean2.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="euclidean2.png")

data1 <- read.csv("euclidean4.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="euclidean4.png")


data1 <- read.csv("manhattan2.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="manhattan2.png")


data1 <- read.csv("manhattan4.csv")

ggplot(data1, aes(attribute0, attribute1)) + geom_point(aes(colour = factor(Cluster)), size = 10, alpha = 7/10)
ggsave(file="manhattan4.png")
