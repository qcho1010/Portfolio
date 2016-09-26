library(data.table)

path<-"./data"

bigram <- readRDS(paste0(path,"/smle.n2.join.rds",sep=""))
trigram <- readRDS(paste0(path,"/smle.n3.join.rds",sep=""))
quadrigram <- readRDS(paste0(path,"/smle.n4.join.rds",sep=""))
wordBank <- readRDS(paste0(path,"/wordBank.rds",sep=""))
wordBank$word <- as.character(wordBank$word)

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
     print("GRAM1")
     result <- c()
     defult <- c("the", "to", "and", "a", "of")
     if (length(grep(string1, bigram$input)) != 0) {     # string is in the DB
          print("GRAM1-1")
          if(idx != 0) {      # called from Backedoff.3, return single value only
               outputX <- paste0("output", idx)
               outputX <- bigram[input == string1 & rank == idx, ]$output
               outputX <- ifelse(length(outputX) == 0, defult[idx], outputX)
               return(outputX)
          }
          for (i in seq(1, 4)) {   # obtain top 5 choices
               outputX <- paste0("output", i)
               outputX <- bigram[input == string1 & rank == i, ]$output
               outputX <- ifelse(length(outputX) == 0, defult[i], outputX)
               result <- c(result, outputX)
          }
     } else if (idx != 0) {   # getting only one missing value from backoff.1
          print("GRAM1-2")
          return(defult[idx])
     } else {
          print("GRAM1-3")
          return(defult)
     }
     
     return(result)
}

Backoff.2 <- function(string1, string2, idx = 0) {
     print("GRAM2")
     result <- c()
     if (length(grep(string2, trigram$input)) != 0) {    # string is in the DB
          print("GRAM2-1")
          print(idx)
          if(idx != 0) {      # called from Backedoff.3, return single value only
               outputX <- paste0("output", idx)
               outputX <- trigram[input == string2 & rank == idx, ]$output
               outputX <- ifelse(length(outputX) == 0, 
                                 Backoff.1(string1, idx=idx), outputX)
               return(outputX)
          }
          
          for (i in seq(1, 4)) {   # obtain top 5 choices
               outputX <- paste0("output", i)
               outputX <- trigram[input == string2 & rank == i, ]$output
               outputX <- ifelse(length(outputX) == 0, 
                                 Backoff.1(string1, idx=i), outputX)
               result <- c(result, outputX)
          }
     } else if (idx != 0) {   # getting only one missing value from backoff.1
          print("GRAM2-2")
          return(Backoff.1(string1, idx))
     } else {    # string isn't in the DB, move to backoff.1
          print("GRAM2-3")
          return(Backoff.1(string1, 0))
     }
     return(result)
}

Backoff.3 <- function(string1, string2, string3) {
     print("GRAM3")
     result <- c()
     if (length(grep(string3, quadrigram$input)) != 0) {    # string is in the DB
          for (i in seq(1, 4)) {   # obtain top 5 choices
               print("GRAM3-2")
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

predictWord <- function(text) {
     text <- splitString(text)
     if (text[1] == 3){
          t<-Backoff.3(text[2], text[3], text[4])
          print(class(t))
          return(t)
     } else if (text[1] == 2) {
          return(Backoff.2(text[2], text[3]))
     } else                 
          return(Backoff.1(text[2]))
}

predictWord2 <- function(text) {
     text <- gsub("[^A-Za-z\']", "", text)
     text <- tolower(text)
     
     index <- grepl(paste0("^", text), wordBank$word)
     result <- wordBank[index, ][1:4]
     return(result)
}

text <- tail(unlist(strsplit("asd asd sad sad adsade2", split = ' ')), 3)
predictWord(text)
text <- tail(unlist(strsplit("i would like b", split = ' ')), 3)
predictWord(text)
text <- tail(unlist(strsplit("i would like to get the fir", split = ' ')), 3)
predictWord(text)


text <- tail(unlist(strsplit("i", split = ' ')), 1)
predictWord2(text)
text <- tail(unlist(strsplit("i would", split = ' ')), 1)
predictWord2(text)
text <- tail(unlist(strsplit("i would like", split = ' ')), 1)
predictWord2(text)
text <- tail(unlist(strsplit("i would like to g", split = ' ')), 1)
predictWord2(text)
text <- tail(unlist(strsplit("i would like to get the fir", split = ' ')), 1)
predictWord2(text)