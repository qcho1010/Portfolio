
require(dplyr)
require(ggmap)

eps = 0.005 / 1000
calls %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  nrow
#[1] 0
crimes %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  nrow
#[1] 0

###### replace center coordinates in permits

permits %>% group_by(lat,lon) %>% summarise(n=n()) %>% data.frame %>% arrange(desc(n)) %>% head
#       lat       lon   n
#1 42.33168 -83.04800 527 <=========  center of village
#2 42.41591 -83.12131  45
#3 42.33250 -83.04975  20
#4 42.33168 -83.04800  19
#5 42.34528 -83.21652  18
#6 42.33438 -83.21604  16

eps = 0.005 / 1000
permits %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  nrow
#[1] 548
permits %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  
            group_by(lat,lon) %>% summarise(n=n()) %>% data.frame %>% arrange(desc(n)) %>% head
permitsCENTERLATLON <- permits %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%
                       select(building) %>% distinct(building)
permitsCENTERLATLON %>% nrow
#[1] 493 distinct buildings with unknwon latlon where coords of center of city is used
permitsF <- permits %>% filter(abs(lat-42.33168) >= eps  | abs(lon - -83.04800) >= eps)
permits %>% nrow
#[1] 7148
permitsF %>% nrow
#[1] 6600
nrow(permits) - nrow(permitsF)
#[1] 548

m <- permitsCENTERLATLON %>%nrow
m
permitsREPLACE <- read.csv("data/lookup_permits_with_center_lat_lon.csv", stringsAsFactors = FALSE)
nrow(permitsREPLACE)
if (m>0 & !exists("permitsREPLACE")){
   print("requesting coordinates...")
   permitsCENTERLATLON$lon=NA
   permitsCENTERLATLON$lat=NA
   permitsCENTERLATLON$query <- paste0(permitsCENTERLATLON$building,", Detroit, MI")
   permitsCENTERLATLON[,c("lon","lat")] <- geocode(permitsCENTERLATLON$query,output="latlon",messaging=FALSE)
   permitsCENTERLATLON$query <- NULL
   write.csv(permitsCENTERLATLON, file="data/lookup_permits_with_center_lat_lon.csv",row.names=FALSE)
   permitsREPLACE <- permitsCENTERLATLON
}


permitsR <- permits %>% 
   left_join(permitsREPLACE,by=c("building")) %>% 
   mutate(lat=ifelse(is.na(lat.y),lat.x,lat.y)) %>%
   mutate(lon=ifelse(is.na(lon.y),lon.x,lon.y)) %>%
   mutate(lat.x=NULL,lat.y=NULL,lon.x=NULL,lon.y=NULL) %>%
   select(building,lat,lon,incident,origin)

permitsR %>%  nrow
#[1] 7148
permitsR %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  nrow
#[1] 0


###### replace center coordinates in violations

violations %>% group_by(lat,lon) %>% summarise(n=n()) %>% data.frame %>% arrange(desc(n)) %>% head
#       lat       lon     n
#1 42.33168 -83.04800 21114  <=========  center of village
#2 42.33438 -83.21604  4467
#3 42.41591 -83.12131  2003
#4 42.34528 -83.21652  1713
#5 42.34563 -83.00881  1372
#6 42.35323 -83.08587  1142

eps = 0.005 / 1000
violations %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%  nrow
#[1] 21114
violations %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>%
            group_by(lat,lon) %>% summarise(n=n()) %>% data.frame %>% arrange(desc(n)) %>% nrow
#[1] 1 => its just one coordinate we have to deal with
        
            
violationsCENTERLATLON <- violations %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>% select(building) %>% distinct(building)
violationsCENTERLATLON %>% nrow
#[1] 7272 => that many distinct buildings with unknown latlon where coords of center of city is used
violationsF <- violations %>% filter(abs(lat-42.33168) >= eps  | abs(lon - -83.04800) >= eps)
violations %>% nrow
#[1] 307801
violationsF %>% nrow
#[1] 286687
nrow(violations) - nrow(violationsF)
#[1] 21114

violationsREPLACE <- read.csv("data/lookup_violations_with_center_lat_lon.csv", stringsAsFactors = FALSE)
n = ifelse(exists("violationsREPLACE"),nrow(violationsREPLACE),0)
n

# replace center lat lon 
# drop 6751 WARREN

if(exists("violationsREPLACE")){
   violationsR <- violations %>% 
      left_join(violationsREPLACE,by=c("building")) %>% 
      mutate(lat=ifelse(is.na(lat.y),lat.x,lat.y)) %>%
      mutate(lon=ifelse(is.na(lon.y),lon.x,lon.y)) %>%
      mutate(lat.x=NULL,lat.y=NULL,lon.x=NULL,lon.y=NULL) %>%
      select(building,lat,lon,incident,origin,Disposition,FineAmt,AdminFee,LateFee,StateFee,CleanUpCost,JudgmentAmt,PaymentStatus) %>% 
      filter(building!="6751 WARREN")
   violationsCENTERLATLON <- violationsR %>% 
                             filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps) %>% 
                             select(building) %>% distinct(building)}
geocodeQueryCheck()
m <- violationsCENTERLATLON %>%nrow
m


if (m>0){
   print("requesting coordinates...")
   violationsCENTERLATLON <- violationsCENTERLATLON %>% head(n=geocodeQueryCheck())
   violationsCENTERLATLON$lon=NA
   violationsCENTERLATLON$lat=NA
   violationsCENTERLATLON$query <- paste0(violationsCENTERLATLON$building,", Detroit, MI")
   violationsCENTERLATLON[,c("lon","lat")] <- geocode(violationsCENTERLATLON$query,output="latlon",messaging=FALSE)
   violationsCENTERLATLON$query <- NULL
   violationsREPLACE <- violationsCENTERLATLON %>% filter(!is.na(lon) & !is.na(lat))
   if(exists("violationsREPLACE")){
	   write.table(violationsREPLACE, file="data/lookup_violations_with_center_lat_lon.csv",
	   sep=",",quote=TRUE,row.names=FALSE,col.names=FALSE,append=TRUE)
	} else {
	   write.csv(violationsREPLACE, file="data/lookup_violations_with_center_lat_lon.csv",row.names=FALSE)
	}
	violationsREPLACE <- read.csv("data/lookup_violations_with_center_lat_lon.csv", stringsAsFactors = FALSE)
}

violationsR <- violations %>% 
   left_join(violationsREPLACE,by=c("building")) %>% 
   mutate(lat=ifelse(is.na(lat.y),lat.x,lat.y)) %>%
   mutate(lon=ifelse(is.na(lon.y),lon.x,lon.y)) %>%
   mutate(lat.x=NULL,lat.y=NULL,lon.x=NULL,lon.y=NULL) %>%
   select(building,lat,lon,incident,origin,Disposition,FineAmt,AdminFee,LateFee,StateFee,CleanUpCost,JudgmentAmt,PaymentStatus)%>% 
   filter(building!="6751 WARREN")

violationsR %>% filter(abs(lat-42.33168) < eps  & abs(lon - -83.04800) < eps)%>%nrow
#[1] 0
