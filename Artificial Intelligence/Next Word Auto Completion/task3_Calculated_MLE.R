library(dplyr)
library(tidyr)

## This script is set up to use as low memory as possible
# UniGrams ----------------------------------------------------------------

## Load Data
if (!exists("sample.n1")) {
     sample.n1<-readRDS("./data/sample.n1.rds")
}

## Split text into separate words
table.n1 <- data.table::data.table(as.data.frame(sample.n1) %>% 
                                        separate(text, into = paste("w", 1, sep = ""), remove = FALSE))

## Cleanup unused data
rm(sample.n1)
gc()


# BiGrams -----------------------------------------------------------------
## Load Data
if (!exists("sample.n2")) {
     sample.n2 <- readRDS("./data/sample.n2.rds")
}

## Split text into separate words
table.n2 <- data.table::data.table(as.data.frame(sample.n2) %>% 
                                        separate(text, into = paste("w", 1:2, sep = ""), remove = FALSE))

 
## Cleanup unused data
rm(sample.n2)
gc()

# TriGrams ----------------------------------------------------------------

## Load Data
if (!exists("sample.n3")) {
     sample.n3 <- readRDS("./data/sample.n3.rds")
}

## Split text into separate words
table.n3 <- data.table::data.table(as.data.frame(sample.n3) %>% 
                                        separate(text, into = paste("w", 1:3, sep = ""), remove = FALSE))

## Cleanup unused data
rm(sample.n3)
gc()


# Quadrigrams -------------------------------------------------------------

## Load Data
if (!exists("sample.n4")) {
     sample.n4 <- readRDS("./data/sample.n4.rds")
}

## Split text into separate words
table.n4 <- data.table::data.table(as.data.frame(sample.n4) %>% 
                                        separate(text, into = paste("w", 1:4, sep = ""), remove = FALSE))

## Cleanup unused data
rm(sample.n4)
gc()

# Calculate Maximum-Likelihood Estimation ---------------------------------
## Join tables for Wx with Wx-1 & calculate MLE
mle.n2 <- dplyr::inner_join(table.n1, table.n2, by = c("w1" = "w1")) %>% 
     mutate(mle = counts.y / counts.x) %>% 
     select(w1, w2, text.x, text.y, counts.x, counts.y, mle)

## Join tables for Wx with Wx-1 & calculate MLE
mle.n3 <- dplyr::inner_join(table.n2, table.n3, by = c("w1" = "w1","w2" = "w2")) %>%
     mutate(mle = counts.y / counts.x) %>% 
     select(w1, w2, w3, text.x, text.y, counts.x, counts.y, mle)

## Join tables for Wx with Wx-1 & calculate MLE
mle.n4 <- dplyr::inner_join(table.n3, table.n4, by = c("w1" = "w1", "w2" = "w2", "w3" = "w3")) %>% 
     mutate(mle = counts.y / counts.x) %>% 
     select(w1, w2, w3, w4, text.x, text.y, counts.x, counts.y, mle)

# Cleanup -----------------------------------------------------------------
saveRDS(table.n1, "./data/table.n1.rds" )
rm(table.n1)
gc()

saveRDS(table.n2, "./data/table.n2.rds" )
rm(table.n2)
gc()

saveRDS(table.n3, "./data/table.n3.rds" )
rm(table.n3)
gc()

saveRDS(table.n4, "./data/table.n4.rds" )
rm(table.n4)
gc()

saveRDS(mle.n2, "./data/mle.n2.rds" )
rm(mle.n2)
gc()

saveRDS(mle.n3, "./data/mle.n3.rds" )
rm(mle.n3)
gc()

saveRDS(mle.n4, "./data/mle.n4.rds" )
rm(mle.n4)
gc()