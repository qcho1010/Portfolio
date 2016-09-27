## SET SAMPLE FRACTION (e.g 0.10 = 10%)
y <- .5

# Read Datasets -----------------------------------------------------------
if (!exists("en_US.blogs.txt")) {
     en_US.blogs.txt <- readRDS("./data/en_US.blogs.txt.rds")
}

if (!exists("en_US.news.txt")) {
     en_US.news.txt <- readRDS("./data/en_US.news.txt.rds" )
}

if (!exists("en_US.twitter.txt")) {
     en_US.twitter.txt <- readRDS("./data/en_US.twitter.txt.rds" )
}

# Samples -----------------------------------------------------------------
## Create sets based on a random sample of 1% of the actual datasets.

set.seed(1)
blogs.sample.1 <- sample(en_US.blogs.txt, size=length(en_US.blogs.txt)*y)
news.sample.1 <- sample(en_US.news.txt, size=length(en_US.news.txt)*y)
twitter.sample.1 <- sample(en_US.twitter.txt, size=length(en_US.twitter.txt)*y)

## cleanup
rm(en_US.blogs.txt, en_US.news.txt, en_US.twitter.txt)
gc()

sample.1 <- c(blogs.sample.1, news.sample.1, twitter.sample.1)

# Dump datasets -----------------------------------------------------------

saveRDS(blogs.sample.1, "./data/blogs.sample.1.rds")
rm(blogs.sample.1)
gc()

saveRDS(news.sample.1, "./data/news.sample.1.rds" )
rm(news.sample.1)
gc()

saveRDS(twitter.sample.1, "./data/twitter.sample.1.rds" )
rm(twitter.sample.1)
gc()

saveRDS(sample.1, "./data/sample.1.rds" )
rm(sample.1)
gc()

rm(y)

# word bank datasets -----------------------------------------------------------
setwd("E:/Google Drive/College/1-Data Science/17-Capston/data")
data <- readLines("freqWord.txt")
# data <- sort(data)

data <- as.list(data)
data <- as.matrix(do.call(cbind, data))
data <- t(data)
data <- as.data.frame(data)

idx <- (nchar(as.character(data$V1)) >= 3)
data <- as.data.frame(data[idx,])
data <- as.data.frame(data[1:5000, ])
colnames(data) <- "word"

sort.df <- with(data,  data[order(word) , ])
sort.df <- as.data.frame(sort.df)
colnames(sort.df) <- "word"

# data <- data.table::data.table(data)
saveRDS(sort.df, "wordBank.rds" )

