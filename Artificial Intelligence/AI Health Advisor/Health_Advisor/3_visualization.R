library(plotly)
library(ggplot2)

setwd("~/Documents/archHack")
canc_data_vis <- read.csv("Health_Advisor/data/canc_data_vis.csv")
heart_data_vis <- read.csv("Health_Advisor/data/heart_data_vis.csv")

# integer list
int_list <- c('age', 'cigarette', 'exercise', 'stress', 'alcohol', 'sugar')

# save proper graph based on each featrues's data type
graph_generator <- function(string, data) {
  for (i in seq(3, ncol(data))) {
    # extract name
    colname <- names(data)[i]
    
    # create plot
    g <- ggplot(data, aes(x = data[, c(i)])) +
      geom_vline(xintercept = mean(data[, c(i)]), color="darkgray", size=3) +
      xlab(colname)
  
    # different types of plots
    if (is.element(colname, int_list)) {
      g <- g + geom_density(fill="blue", alpha = 0.2) 
    } else {
      g <- g + geom_density(fill="red", alpha = 0.2)
    }
    
    # save data
    colname <- paste0(string, colnames(data)[i])
    dir <- paste0("Health_Advisor/data/graph/g_", colname, ".rds")
    saveRDS(g, file=dir)
    print(paste(colname, "Saved"))
    
    # g_canc_age <-readRDS(dir)
    # print(g_canc_age)
    
  }
}


graph_generator("canc_", canc_data_vis)
graph_generator("heart_", heart_data_vis)

################### testing #####################
# # extract name
# colname <- names(canc_data_vis)[3]
# 
# # create plot
# g <- ggplot(canc_data_vis, aes(x = canc_data_vis$age)) +
#   geom_vline(xintercept = mean(canc_data_vis$age), color="darkgray", size=3) +
#   xlab(colname)
# 
# # different types of plots
# if (typeof(canc_data_vis$age) == 'integer') {
#   print("hie")
#   g <- g + geom_density(fill="blue", alpha = 0.2) 
# } else {
#   g <- g+ geom_histogram(fill="red", alpha = 0.2)
# }
# 
# g
# 
# # save data
# colname <- paste0(string, colnames(data)[i])
# dir <- paste0("Health_Advisor/data/graph/g_", colname, ".rds")
# saveRDS(g, file=dir)
# print(paste(colname, "Saved"))

