# https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html
# https://cran.r-project.org/web/packages/dplyr/vignettes/two-table.html

require(dplyr)
options(dplyr.width = Inf)
require(ggmap)

# backup unfiltered data
callsRAW      = calls
violationsRAW = violations
crimesRAW     = crimes
permitsRAW    = permits


# count missing coords:
calls      %>% select(building,lat,lon) %>% filter(is.na(lat) | is.na(lon)) %>% nrow
violations %>% select(building,lat,lon) %>% filter(is.na(lat) | is.na(lon)) %>% nrow
crimes     %>% select(building,lat,lon) %>% filter(is.na(lat) | is.na(lon)) %>% nrow
permits    %>% select(building,lat,lon) %>% filter(is.na(lat) | is.na(lon)) %>% nrow
# [1] 0
# [1] 0
# [1] 30
# [1] 817 => ALL addresses with double blanks in SITE_ADDRESS have missing location!

# assign multiple return values to multiple columns
# http://stackoverflow.com/a/19533807
#geocodeQueryCheck()
#test <- data.frame(building=c("4331 BARHAM","10803 STRATMANN","15408 WEST PARKWAY"),lat=NA,lon=NA)
#test
#test[,c("lon","lat")]
#test[,c("lon","lat")] <- c(1,1)
#test$query <- paste0(test$building,", Detroit, MI")
#test
#test[,c("lon","lat")] <- geocode(test$query,output="latlon",override_limit=T,messaging=FALSE)
#test


###################### lookup missing coordinates

permitsNA <- permits %>% select(building,lat,lon) %>% filter(is.na(lat) | is.na(lon))
m <- permitsNA %>% filter(is.na(lat)|is.na(lon)) %>%nrow
m
#[1] 817
permitsLookup <- read.csv("data/lookup_permits.csv", stringsAsFactors = FALSE)
nrow(permitsLookup)
#[1] 817

if (m>0 & !exists("permitsLookup")){
   print("requesting coordinates...")
   permitsNA$query <- paste0(permitsNA$building,", Detroit, MI")
   permitsNA[,c("lon","lat")] <- geocode(permitsNA$query,output="latlon",messaging=FALSE)
   permitsNA$query <- NULL
   write.csv(permitsNA, file="data/lookup_permits.csv",row.names = FALSE)
   permitsLookup <- permitsNA
}

permits <- permitsRAW %>% 
   left_join(permitsLookup,by=c("building")) %>% 
   mutate(lat=ifelse(is.na(lat.y),lat.x,lat.y)) %>%
   mutate(lon=ifelse(is.na(lon.y),lon.x,lon.y)) %>%
   mutate(lat.x=NULL,lat.y=NULL,lon.x=NULL,lon.y=NULL)
   
permits %>% filter(is.na(lat) | is.na(lon)) %>% nrow

# backup unfiltered data
callsRAW      = calls
violationsRAW = violations
crimesRAW     = crimes
permitsRAW    = permits


# drop missing coords:
calls      = callsRAW      %>% select(building,lat,lon,incident,origin) %>% filter(!is.na(lat) & !is.na(lon))
crimes     = crimesRAW     %>% select(building,lat,lon,incident,origin) %>% filter(!is.na(lat) & !is.na(lon))
permits    = permitsRAW    %>% select(building,lat,lon,incident,origin) %>% filter(!is.na(lat) & !is.na(lon))
violations = violationsRAW %>% 
             select(building,lat,lon,incident,origin,Disposition,FineAmt,AdminFee,LateFee,StateFee,CleanUpCost,JudgmentAmt,PaymentStatus) %>% 
             filter(!is.na(lat) & !is.na(lon))

# count locations outside Detroit:
calls      %>% filter(!(42<lat & lat<43 & -83.3<lon & lon< -82.9)) %>% nrow
violations %>% filter(!(42<lat & lat<43 & -83.3<lon & lon< -82.9)) %>% nrow
crimes     %>% filter(!(42<lat & lat<43 & -83.3<lon & lon< -82.9)) %>% nrow
permits    %>% filter(!(42<lat & lat<43 & -83.3<lon & lon< -82.9)) %>% nrow
# [1] 1
# [1] 0
# [1] 407
# [1] 1

#drop locations outside Detroit
calls      %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9) -> calls
violations %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9) -> violations
crimes     %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9) -> crimes
permits    %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9) -> permits

#count remaining records:
calls      %>% nrow
violations %>% nrow
crimes     %>% nrow
permits    %>% nrow
# [1] 19680
# [1] 307801
# [1] 119901
# [1] 7148
