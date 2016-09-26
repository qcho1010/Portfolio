library(dplyr)
library(data.table)
path <- "./data"

# BiGram ------------------------------------------------------------------
## Read the RDS
smle.n2 <- readRDS(paste0(path,"/smle.n2.rds", sep="" ))

## use setkey to speed up sorting
setkey(smle.n2, text.x, smle)

# Delete char that less than 1
smle.n4 <- smle.n2[nchar(smle.n2$w2) > 1,]

# For visualization
## Select Top-30 predictions
smle.n2V <- select(smle.n2, input = w1, output = w2, smle, counts.y) %>% 
     group_by(input) %>% 
     top_n(30, smle)
smle.n2V$smle <- round(smle.n2V$smle, 4) 

## Add a rank using data table
smle.n2V <- smle.n2V[, rank := rank(-smle , ties.method = "first"), by = input]
smle.n2V.join <- smle.n2V

## Save the results and cleanup
saveRDS(smle.n2V.join, "./data/smle.n2V.join.rds")
rm(smle.n2V.join, smle.n2V)
gc()


## Select Top-5 predictions
smle.n2 <- select(smle.n2, input = w1, output = w2, smle) %>% 
     group_by(input) %>% 
     top_n(5, smle)
smle.n2$smle <- round(smle.n2$smle, 4) 

## Add a rank using data table
smle.n2 <- smle.n2[, rank := rank(-smle , ties.method = "first"), by = input]
smle.n2.join <- smle.n2
smle.n2.join$smle <- NULL

## Save the results and cleanup
saveRDS(smle.n2.join, "./data/smle.n2.join.rds")
rm(smle.n2)
gc()

# TriGram -----------------------------------------------------------------
## Read the RDS
smle.n3 <- readRDS("./data/smle.n3.rds")

## use setkey to speed up sorting
setkey(smle.n3, text.x, smle)

# Delete char that less than 1
smle.n3 <- smle.n3[nchar(smle.n3$w2) > 1,]

# For visualization
## Select Top-30 predictions
smle.n3V <- select(smle.n3, input = text.x, output = w3, smle, counts.y) %>% 
     group_by(input) %>% 
     top_n(30, smle)
smle.n3V$smle <- round(smle.n3V$smle, 4) 

## Add a rank using data table
smle.n3V <- smle.n3V[, rank := rank(-smle , ties.method = "first"), by = input]
smle.n3V.join <- smle.n3V

## Save the results and cleanup
saveRDS(smle.n3V.join, "./data/smle.n3V.join.rds")
rm(smle.n3V.join, smle.n3V)
gc()


## Select Top-5 predictions
smle.n3 <- select(smle.n3, input = text.x, output = w3, smle) %>% 
     group_by(input) %>% 
     top_n(5)
smle.n3$smle <- round(smle.n3$smle, 4) 

## Add a rank
smle.n3 <- smle.n3[,rank:= rank(-smle,ties.method = "first"), by = input]
smle.n3.join <- smle.n3
smle.n3.join$smle <- NULL

## Save the results and cleanup
saveRDS(smle.n3.join, "./data/smle.n3.join.rds")
rm(smle.n3.join,smle.n3)
gc()


# QuadriGram --------------------------------------------------------------
## Read the RDS
smle.n4 <- readRDS("./data/smle.n4.rds")

## use setkey to speed up sorting
setkey(smle.n4, text.x, smle)

# Delete char that less than 1
smle.n4 <- smle.n4[nchar(smle.n4$w2) > 1,]

# For visualization
## Select Top-30 predictions
smle.n4V <- select(smle.n4, input = text.x, output = w4, smle, counts.y) %>% 
     group_by(input) %>% 
     top_n(30, smle)
smle.n4V$smle <- round(smle.n4V$smle, 4) 

## Add a rank using data table
smle.n4V <- smle.n4V[, rank := rank(-smle , ties.method = "first"), by = input]
smle.n4V.join <- smle.n4V

## Save the results and cleanup
saveRDS(smle.n4V.join, "./data/smle.n4V.join.rds")
rm(smle.n4V.join, smle.n4V)
gc()


## Select Top-5 predictions
smle.n4 <- select(smle.n4, input = text.x, output = w4, smle) %>% 
     group_by(input) %>% 
     top_n(5, smle)
smle.n4$smle <- round(smle.n4$smle, 4) 

## Add a rank
smle.n4 <- smle.n4[, rank:= rank(-smle,ties.method = "first"), by = input]
smle.n4.join <- smle.n4
smle.n4.join$smle <- NULL

## Save the results and cleanup
saveRDS(smle.n4.join, "./data/smle.n4.join.rds")
rm(smle.n4.join, smle.n4)
gc()
