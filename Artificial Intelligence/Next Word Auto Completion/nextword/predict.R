library(data.table)

path<-"./data"

bigram <- readRDS(paste0(path,"/smle.n2.join.rds",sep=""))
trigram <- readRDS(paste0(path,"/smle.n3.join.rds",sep=""))
quadrigram <- readRDS(paste0(path,"/smle.n4.join.rds",sep=""))
wordBank <- readRDS(paste0(path,"/wordBank.rds",sep=""))
wordBank$word <- as.character(wordBank$word)

bigramV <- readRDS(paste0(path,"/smle.n2V.join.rds",sep=""))
trigramV <- readRDS(paste0(path,"/smle.n3V.join.rds",sep=""))
quadrigramV <- readRDS(paste0(path,"/smle.n4V.join.rds",sep=""))

splitString <- function(text) {
     text <- gsub("[^A-Za-z\']", "", text)
     text <- tolower(text)
     text <- text[text != ""]
     if (length(text) == 3)  {
          gram <- 3
          string3 <- paste0(tail(text, 3), collapse = " ")
          string2 <- paste0(tail(text, 2), collapse = " ")
          string1 <- paste0(tail(text, 1), collapse = " ")
     } else if (length(text) == 2){
          gram <- 2
          string3 <- NA
          string2 <- paste0(tail(text, 2), collapse  = " ")
          string1 <- paste0(tail(text, 1), collapse  = " ")
     } else {
          gram <- 1
          string3 <- NA
          string2 <- NA
          string1 <- paste0(tail(text, 1), collapse = " ")
     }
     return(c(gram, string1, string2, string3))
}

Backoff.1 <- function(string1, idx = 0) {
     result <- c()
     defult <- c("the", "to", "and", "a", "of")
     if (length(grep(string1, bigram$input)) != 0) {     # string is in the DB
          if(idx != 0) {      # called from Backedoff.3, return single value only
               outputX <- paste0("output", idx)
               outputX <- bigram[input == string1 & rank == idx, ]$output
               outputX <- ifelse(length(outputX) == 0, defult[idx], outputX)
               return(outputX)
          }
          for (i in seq(1, 5)) {   # obtain top 5 choices
               outputX <- paste0("output", i)
               outputX <- bigram[input == string1 & rank == i, ]$output
               outputX <- ifelse(length(outputX) == 0, defult[i], outputX)
               result <- c(result, outputX)
          }
     } else if (idx != 0) {   # getting only one missing value from backoff.1
          return(defult[idx])
     } else {
          return(defult)
     }
     
     return(result)
}

Backoff.2 <- function(string1, string2, idx = 0) {
     result <- c()
     if (length(grep(string2, trigram$input)) != 0) {    # string is in the DB
          if(idx != 0) {      # called from Backedoff.3, return single value only
               outputX <- paste0("output", idx)
               outputX <- trigram[input == string2 & rank == idx, ]$output
               outputX <- ifelse(length(outputX) == 0, 
                                 Backoff.1(string1, idx=idx), outputX)
               return(outputX)
          }
          
          for (i in seq(1, 5)) {   # obtain top 5 choices
               outputX <- paste0("output", i)
               outputX <- trigram[input == string2 & rank == i, ]$output
               outputX <- ifelse(length(outputX) == 0, 
                                 Backoff.1(string1, idx=i), outputX)
               result <- c(result, outputX)
          }
     } else if (idx != 0) {   # getting only one missing value from backoff.1
          return(Backoff.1(string1, idx))
     } else {    # string isn't in the DB, move to backoff.1
          return(Backoff.1(string1, 0))
     }
     return(result)
}

Backoff.3 <- function(string1, string2, string3) {
     result <- c()
     if (length(grep(string3, quadrigram$input)) != 0) {    # string is in the DB
          for (i in seq(1, 5)) {   # obtain top 5 choices
               outputX <- paste0("output", i)
               outputX <- quadrigram[input == string3 & rank == i, ]$output
               outputX <- ifelse(length(outputX) == 0, 
                                 Backoff.2(string1, string2, idx=i), outputX)
               result <- c(result, outputX)
          }
     } else    # string isn't in the DB, move to Backoff.2
          return(Backoff.2(string1, string2, 0))
     
     return(result)
}

# Next word prediction function
predictWord <- function(text) {
     text <- splitString(text)
     if (text[1] == 3){
          t <- Backoff.3(text[2], text[3], text[4])
          return(t)
     } else if (text[1] == 2) {
          return(Backoff.2(text[2], text[3]))
     } else                 
          return(Backoff.1(text[2]))
}

# Auto completion function
predictWord2 <- function(text) {
     text <- gsub("[^A-Za-z\']", "", text)
     text <- tolower(text)
     
     index <- grepl(paste0("^", text), wordBank$word)
     result <- wordBank[index, ][1:5]
     return(result)
}

# Returning cleaned/sorted table for visualization
getTable <- function(text, length) {
     if (length == 3) {
          string3 <- paste0(tail(text, 3), collapse = " ")
          string2 <- paste0(tail(text, 2), collapse = " ")
          string1 <- paste0(tail(text, 1), collapse = " ")
          df1 <- quadrigramV[input == string3,] 
          df2 <- trigramV[input == string2,] 
          df3 <- bigramV[input == string1,] 
          dff <- rbind(df1, df2, df3)
     } else if (length == 2) {
          string2 <- paste0(tail(text, 2), collapse = " ")
          string1 <- paste0(tail(text, 1), collapse = " ")
          
          df1 <- trigramV[input == string2,] 
          df2 <- bigramV[input == string1,] 
          dff <- rbind(df1, df2)
     } else if (length == 1) {
          string1 <- paste0(tail(text, 1), collapse = " ")
          dff <- bigramV[input == string1,] 
     }
     # print(head(dff))
     dff$rank <- NULL
     return(dff[rev(order(dff$smle)),])
}
