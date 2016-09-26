###########################
# Explore titanic data 
###########################

write  <- FALSE # Plot if FALSE, Write plots to file if TRUE  

###########################
# Load libraries and set working directory 
###########################

library( ggplot2 )
library( reshape )
setwd("E:/Google Drive/kaggle/01-titanic/data")

###########################
# Clean data for R 
# 1. Read data 
# 2. Replace '?' used in Weka for NAs 
# 3. Make sure that features have the right class
###########################
d <- read.csv("trainClean.csv",head=T) 
d[ d == "?" ] <- NA 
d$Survived  <- as.factor( d$Survived ) # 
d$Pclass  <- as.factor( d$Pclass )
d$Age <- as.numeric( as.character( d$Age ) ) 

d$TicketNr <- as.numeric( as.character( d$TicketNr ) ) 
d$CabinCount <- as.numeric( as.character( d$CabinCount ) ) 
d$CabinNr <- as.numeric( as.character( d$CabinNr ) ) 

###########################
# What is the prior propability of survival? 
###########################
survived.fraction <- sum( as.numeric( as.character( d$Survived ) ) ) / length( d$Survived )

###########################
# NOMINAL FEATURES
# 1. Subset data for nominal features
# 2. Calculate fraction survived for each class within the nominal features 
###########################
d.nominal  <- d[,which( sapply(d, is.factor ) ) ]
d.nominal.features  <- names( d.nominal )[ which( names( d.nominal ) != "Survived" ) ]
d.nominal$Survived  <- as.numeric( as.character( d.nominal$Survived ) )

# Get n,k and p for each class for each nominal feature. 
fraction.survived <- function( featureName, d.nominal ) {
     index  <- which( names( d.nominal ) == featureName ) 
     df <- data.frame( value=d.nominal[,index], sex=d.nominal$Sex, Survived=d.nominal$Survived )
     df  <- df[ !is.na( df$value ), ]
     
     fraction.survived.perLevel <- function( level ) {
          df.levelsub <- df[ df$value == level, ]
          k <- sum( df.levelsub$Survived )
          n <- length( df.levelsub$value )
          out  <- data.frame( feature=featureName, value=level, k=k, n=n, fractionSurvived=k/n )
          return(  out ) 
     }
     
     out  <- data.frame() 
     for( i in levels( df$value ) ) {
          if( i != "?" ) { out <- rbind( out, fraction.survived.perLevel( i ) )  }
     }
     return( out )
}

# Get fraction survival for nominal features
nominal.fractionSurvived  <- data.frame() 
for( i in d.nominal.features ) {
     nominal.fractionSurvived <- rbind( nominal.fractionSurvived, fraction.survived( i, d.nominal ) )
}

#############################
# Are fractions significantly different from what we expect? 
# 1. Example getting k survivors out of 314 female passengers. 
# 2. Calculate a pValue for each class for each feature. Let's model the fraction survived as a bernouli trial with n="number of passengers in each class" 
# and p = "average survival rate".
#############################

# Example: Probability of k survivors with n=314, p=0.38
example.n <- 314
example.df <- data.frame( k=seq( from=0, to=example.n, by=1 ) ) 
example.df$p  <- apply( example.df, MARGIN=1, function( x ) dbinom( x, size=example.n, prob=survived.fraction ) )

p <- ggplot( example.df, aes( k, p) )
p <- p + geom_point()
p <- p + geom_vline( aes( xintercept = 233 ),colour="gray50" )
p  <- p + scale_x_continuous( name="survivors k" )
p  <- p + scale_y_continuous( name="probability" )

if( write ) {
     fileName <- "exploration/femaleSurvivorsVsNullHypothesis.png"
     png( fileName )
     show( p )
     dev.off()  
} else {
     quartz()
     show( p )
}

# Perform binomial test for each class and correct the pValue for multiple hypothesis testing
binomialTestPValue <- function( row ) {
     k <- as.numeric( row[ 3 ] )
     n <- as.numeric( row[ 4 ] )
     test <- binom.test( x=k, n=n, p=survived.fraction )
     return( test$p.value )
}
nominal.fractionSurvived$pValue <- apply( nominal.fractionSurvived, MARGIN=1, binomialTestPValue )
nominal.fractionSurvived$pValue <- p.adjust( nominal.fractionSurvived$pValue, method="bonferroni")

# Keep those nominal features with pValues < 0.01
featuresWithLowPValue <- unique( nominal.fractionSurvived[ nominal.fractionSurvived$pValue < 0.01, ]$feature )
keep  <- as.character( featuresWithLowPValue )

# Plot features with at least one class with pValue < 0.01 and 10 passengers
nominal.fractionSurvived <- nominal.fractionSurvived[ nominal.fractionSurvived$feature %in% featuresWithLowPValue, ] 
nominal.fractionSurvived.plot <- nominal.fractionSurvived[ nominal.fractionSurvived$n >= 10, ] 

p <- ggplot( nominal.fractionSurvived.plot, aes( x = factor( value ), y = fractionSurvived, width=n/450 )  )
p <- p + geom_bar( stat = "identity",fill="white", colour="darkgreen" )
p <- p + geom_hline( aes( yintercept = survived.fraction ),colour="gray50" )
p <- p + facet_wrap( ~ feature, scale="free",  )
p  <- p + scale_y_continuous( limits=c(0,1), name="fraction survived" )

if( write ) {
     fileName <- "exploration/nominalFeaturesBarplots.png"
     png( fileName )
     show( p )
     dev.off()  
} else {
     quartz()
     show( p )
}

###########################
# NUMERICAL FEATURES
# Test which features have signficant distinct values for survived vs. diseased. 
# 1. Subset data for numeric features + class feature (Survived)
# 2. Perform 2-sample Kolmogorov-Smirnov test.    
###########################
d.numeric  <- d[,which( sapply(d, is.numeric) ) ]
d.numeric.features  <- names( d.numeric )
d.numeric$Survived  <- d$Survived

kolmogorov.test <- function( featureName, d.numeric ) {
     index  <- which( names( d.numeric ) == featureName ) 
     df <- data.frame( value=d.numeric[,index], Survived=d.numeric$Survived )
     
     notSurvived <- df[ df$Survived == 0 , 1 ]
     survived <- df[ df$Survived == 1 , 1 ]
     test  <- ks.test( survived, notSurvived )
     return( test$p.value  )
}

pValues.numeric  <- sapply( d.numeric.features, function ( x ) kolmogorov.test( x, d.numeric ) )
pValues.numeric  <- p.adjust(p=pValues.numeric,method="bonferroni")
###########################
# Plot data using empirical cumulative distributions
# 1. Scale all numerical values between 0 and 1 
# 2. Reformat the data such that each row contains the numeric value, the feature and the survival
# 3. Plot   
###########################
d.numeric  <- d[,which( sapply(d, is.numeric) ) ]
d.numeric.scaled  <- data.frame( apply( d.numeric, MARGIN=2, function( x ) ( x - min( x, na.rm=T ) ) / diff( range( x, na.rm=T ) ) ) )
d.numeric.scaled$Survived  <- d$Survived

d.numeric.scaled.melt <- ( melt( d.numeric.scaled ) )
d.numeric.scaled.melt <- d.numeric.scaled.melt[ !is.na( d.numeric.scaled.melt$value ), ]

p <- ggplot( d.numeric.scaled.melt, aes( value, colour = Survived ) )
p <- p + stat_ecdf() 
p <- p + facet_wrap(~ variable, ncol=4 )
p  <- p + scale_x_continuous( limits=c(0,1), breaks=c(0,1.0), name="scaled value" )
p  <- p + scale_y_continuous( limits=c(0,1), name="cumulative probability" )

write <- TRUE
if( write ) {
     fileName <- "exploration/numericFeaturesECDF.png"
     png( fileName )
     show( p )
     dev.off()  
} else {
     quartz() 
     show( p )
}