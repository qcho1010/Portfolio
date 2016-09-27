library(data.table)
path<-"./data"

# Read Datasets -----------------------------------------------------------
## moved to n-gram sections in order to save memory as much as possible.

# Apply Smoothing ---------------------------------------------------------

## This is code acts as a "stub/driver" 
## It copies the mle as smoothed mle for script 6


# Ney et al. estimate the discount value D based on the total number
# of n-grams occurring exactly once (n1) and twice (n2) [CG99]:
#        D= n1 /n1 + 2n2


## How many times does "condition" appear as a novel continuation?
##continuation count =
#sum(mle.n2[w2=="condition",counts.y])

##Pcontination(w) = count normalized by the total number of word bigram types
#sum(mle.n2[w2=="condition",counts.y])/nrow(mle.n2)

# BiGrams -----------------------------------------------------------------
## Read the RDS
mle.n2 <- readRDS(paste0(path,"/mle.n2.rds", sep="" ))

## discard rows that occur only once
mle.n2 <- mle.n2[counts.y > 5, ]

## determine the default value
mle.n2.deafult <- unique(mle.n2[counts.x == max(mle.n2$counts.x), w1])

## Create a new table with a copy of mle
smle.n2 <- cbind(mle.n2, mle.n2[, mle.n2$mle])

## rename the mle copy to smle
setnames(smle.n2, "V2", "smle")

## Save the RDS..
saveRDS(smle.n2, "./data/smle.n2.rds" )

##  ...and clean up afterwards.
rm(smle.n2,mle.n2)
gc()

# TriGrams ----------------------------------------------------------------
## Read the RDS
mle.n3 <- readRDS(paste0(path,"/mle.n3.rds", sep="" ))

## discard rows that occur only once
mle.n3 <- mle.n3[counts.y > 5,]

## Create a new table with a copy of mle
smle.n3 <- cbind(mle.n3, mle.n3[, mle.n3$mle])

## rename the mle copy to smle
setnames(smle.n3, "V2", "smle")

## Save the RDS..
saveRDS(smle.n3, "./data/smle.n3.rds" )

##  ...and clean up afterwards.
rm(smle.n3,mle.n3)
gc()

# QuadriGrams -------------------------------------------------------------
## Read the RDS
mle.n4 <- readRDS(paste0(path,"/mle.n4.rds", sep="" ))

## discard rows that occur only once
mle.n4 <- mle.n4[counts.y > 5,]

## Create a new table with a copy of mle
smle.n4 <- cbind(mle.n4, mle.n4[,mle.n4$mle])

## rename the mle copy to smle
setnames(smle.n4,"V2","smle")

## Save the RDS..
saveRDS(smle.n4, "./data/smle.n4.rds" )

##  ...and clean up afterwards.
rm(smle.n4,mle.n4)
gc()