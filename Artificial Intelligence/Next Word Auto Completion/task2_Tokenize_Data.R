# Call Packages -----------------------------------------------------------
library(quanteda)
library(tau)
library(tm)

# Read Datasets -----------------------------------------------------------

sample.1 <- readRDS("./data/sample.1.rds")

# Clean Data --------------------------------------------------------------
cleanData <- function(text){
     ## convert to lowercase
     text <- tolower(text)
     
     ## Clean the breviated words
     text <- gsub("i'm", "i am", text)
     text <- gsub("you're", "you are", text)
     text <- gsub("we're", "we are", text)
     text <- gsub("they're", "they are", text)
     text <- gsub("he's", "he is", text)
     text <- gsub("she's", "she is", text)
     text <- gsub("it's", "it is", text)
     text <- gsub("what's", "what is", text)
     text <- gsub("what're", "what are", text)
     text <- gsub("i'll", "i will", text)
     text <- gsub("you'll", "you will", text)
     text <- gsub("we'll", "we will", text)
     text <- gsub("they'll", "they will", text)
     text <- gsub("he'll", "he will", text)
     text <- gsub("she'll", "she will", text)
     text <- gsub("it'll", "it will", text)
     text <- gsub("i've", "i have", text)
     text <- gsub("you've", "you have", text)
     text <- gsub("they've", "they have", text)
     text <- gsub("i'd", "i had", text)
     text <- gsub("you'd", "you had", text)
     text <- gsub("we'd", "we had", text)
     text <- gsub("they'd", "they had", text)
     text <- gsub("he'd", "he had", text)
     text <- gsub("she'd", "she had", text)
     text <- gsub("it'd", "it had", text)
     text <- gsub("haven't", "have not", text)
     text <- gsub("hasn't", "has not", text)
     text <- gsub("isn't", "is not", text)
     text <- gsub("aren't", "are not", text)
     text <- gsub("weren't", "were not", text)
     text <- gsub("wasn't", "was not", text)
     text <- gsub("don't", "do not", text)
     text <- gsub("did't", "did not", text)
     text <- gsub("doesn't", "does not", text)
     text <- gsub("can't", "can not", text)
     text <- gsub("couldn't", "could not", text)
     text <- gsub("won't", "will not", text)
     text <- gsub("wouldn't", "would not", text)
     
     ## remove bad words
     text <- gsub("[a-z]*fuck+[a-z]*", "", text)
     text <- gsub("[a-z]*ass+[a-z]*", "", text)

     ## remove e-mail adresses
     text <- gsub("[[:alnum:].-]+@[[:alnum:].-]+"," ",text ) 
     
     ## remove twitter accounts
     text <- gsub("@[^\\s]+", " ", text)
     
     ## remove non-alphanumerics
     text <- gsub("[^A-Za-z\']"," ",text)
     
     ## remove extra whitespaces 
     text <- gsub("\\s+"," ",text)
     return(text)
}

#Removes bad words
profanityFilter <- function(text) {
     badwords <- readLines("./data/en_profanity.txt")
     text <- removeWords(text, badwords)
     text
}
# sample.1
text <- grep("what's", sample.1)
text <- grep("did't", sample.1)
# 
# sample.1 <- readRDS("./data/sample.n1.rds")
# sample.2 <- readRDS("./data/sample.n2.rds")
# sample.3 <- readRDS("./data/sample.n3.rds")
# sample.4 <- readRDS("./data/sample.n4.rds")


# run the function
sample.1 <- profanityFilter(sample.1)
sample.1 <- cleanData(sample.1)

# Tokenize the data -------------------------------------------------------
sample.1.corpus <- quanteda::tokenize(sample.1, what = "word",
                                      removeNumbers = TRUE, removePunct = TRUE, 
                                      removeSeparators = TRUE, removeHyphens = TRUE)

##Define a function to create n-grams.
createNGram <- function(text, n){
     x <- tau::textcnt(x = text, tolower = TRUE, 
                     method = "string", n = n, decreasing=TRUE)
     return(x)
}

## Run the n-grams and dump the results
## remove any unneeded datasets 
sample.n1 <- createNGram(sample.1.corpus, 1)
sample.n1 <- data.frame(counts = unclass(sample.n1), text=(names(sample.n1)), stringsAsFactors = FALSE)
rownames(sample.n1) <- NULL
sample.n1 <- data.table::data.table(sample.n1)
saveRDS(sample.n1, "./data/sample.n1.rds")
rm(sample.n1)
gc()

sample.n2 <- createNGram(sample.1.corpus,2)
sample.n2 <- data.frame(counts = unclass(sample.n2),text=(names(sample.n2)), stringsAsFactors = FALSE)
rownames(sample.n2) <- NULL
sample.n2 <- data.table::data.table(sample.n2)
saveRDS(sample.n2, "./data/sample.n2.rds")
rm(sample.n2)
gc()

sample.n3 <- createNGram(sample.1.corpus,3)
sample.n3 <- data.frame(counts = unclass(sample.n3),text=(names(sample.n3)), stringsAsFactors = FALSE)
rownames(sample.n3) <- NULL
sample.n3 <- data.table::data.table(sample.n3)
saveRDS(sample.n3, "./data/sample.n3.rds")
rm(sample.n3)
gc()

sample.n4 <- createNGram(sample.1.corpus,4)
sample.n4 <- data.frame(counts = unclass(sample.n4),text=(names(sample.n4)), stringsAsFactors = FALSE)
rownames(sample.n4) <- NULL
sample.n4 <- data.table::data.table(sample.n4)
saveRDS(sample.n4, "./data/sample.n4.rds")
rm(sample.n4)
gc()

