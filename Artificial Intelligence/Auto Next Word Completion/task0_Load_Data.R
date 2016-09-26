setwd("E:/Google Drive/College/1-Data Science/17-Capston")

# # load data
# blogs <- readLines("./data/final/en_US/en_US.blogs.txt")
# news <- readLines("./data/final/en_US/en_US.news.txt")
# twitter <- readLines("./data/final/en_US/en_US.twitter.txt", skipNul = TRUE) 
# 
# # save data
# save(blogs, news, twitter, file = "raw_data.Rdata")

# Download Dataset --------------------------------------------------------
## create a subdirectory
if (!file.exists("./data")) {
     dir.create("./data")
}

## set the file URLs
fileUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

## check if the download file exist. Download only if it doesn't exist
if (!file.exists("./data/Coursera-SwiftKey.zip")) {
     download.file(fileUrl,destfile = "./data/Coursera-SwiftKey.zip",method = "curl")
}

## check if the file is unzipped. Unpack only if it doesn't exist
if (!file.exists("./data/final/en_US")) {
     unzip("./data/Coursera-SwiftKey.zip", exdir="./data")
}

## Get the file names from the directory
file.names <- dir("./data/final/en_US")


# Load Data ---------------------------------------------------------------
## Load the data
for (i in 1:length(file.names))
     assign(file.names[i], readLines(paste0("./data/final/en_US/",file.names[i])))


## Create one total dataset
total.set <- c(en_US.blogs.txt, en_US.news.txt, en_US.twitter.txt)


# Dump datasets -----------------------------------------------------------
if (!file.exists("./data/en_US.blogs.txt.rds")) {
     saveRDS(en_US.blogs.txt, "./data/en_US.blogs.txt.rds")
}

if (!file.exists("./data/en_US.news.txt.rds")) {
     saveRDS(en_US.news.txt, "./data/en_US.news.txt.rds" )
}


if (!file.exists("./data/en_US.twitter.txt.rds")) {
     saveRDS(en_US.twitter.txt, "./data/en_US.twitter.txt.rds" )
}


if (!file.exists("./data/total.set.rds")) {
     saveRDS(total.set, "./data/total.set.rds" )
}

## optional
rm(en_US.blogs.txt, en_US.news.txt, en_US.twitter.txt,total.set)
gc()

