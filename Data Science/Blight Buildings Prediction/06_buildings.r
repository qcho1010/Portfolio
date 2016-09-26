


###############################  clustering around center of town

vioN <- violationsSUB %>% select(lat,lon) %>% group_by(lat,lon) %>% summarise(n=n())
dvioN %>% arrange(desc(n))		# fails!
dplyr::arrange(vioN, desc(n))	# fails!
vioN %>% data.frame() %>% arrange(desc(n)) %>% head # OK
vioN %>% ungroup %>% arrange(desc(n)) %>% head		# OK
plyr::arrange(vioN, desc(n))	# OK
vioN[order(desc(vioN$n)), ]		# OK


permitsAGG %>% nrow
crimesAGG %>% nrow
callsAGG %>% nrow
violationsAGG %>% nrow
pn = permitsAGG %>% nrow
cn = crimesAGG %>% nrow
an = callsAGG %>% nrow
vn = violationsAGG %>% nrow
pn + cn + an + vn


buildings <- rbind(permits,crimes,calls,violations) %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9)
buildings %>% nrow
#[1] 454122

buildings <- rbind(permitsR,crimes,calls,violationsR) %>% filter(42<lat & lat<43 & -83.3<lon & lon< -82.9)
buildings %>% nrow
#[1] 454122


buildingsAGG = buildings %>% 
             group_by(building) %>% 
             summarise(n=n(),south=min(lat),north=max(lat),west=min(lon),east=max(lon)) %>%
             select(building,n,north,south,west,east) %>%
             mutate(size=(north-south)*(east-west))
buildingsAGG %>% filter(size>0) %>% select(building, size) %>% arrange(desc(size))
buildingsSUBMIT = buildings %>% 
             group_by(building) %>% 
             summarise(lat=mean(lat),lon=mean(lon))

############# 

buildings %>% nrow
buildingsAGG %>% nrow
buildingsSUBMIT %>% nrow
#[1] 454122
#[1] 184522
#[1] 184522


############# spatial

#apt-get install libxml2-dev
#apt-get install libgdal-dev
#apt-get install libproj-dev
#install.packages(c("XML","rgdal","rgeos","osmar","tmap"))

require(sp)

distmeter <- function(x1,y1,x2,y2) return(1000*spDistsN1(matrix(c(x1,y1),ncol=2),c(x2,y2),longlat=T))

# millidegree to meters
xmeter = distmeter(-83.001,42,-83,42)
xmeter
#[1] 82.85069   => one millidegree is 82m in x direction
ymeter = distmeter(-83,42.001,-83,42)
ymeter
#[1] 110.9713   => one millidegree is 110m in y direction

distpythagoras <- function(x1,y1,x2,y2) (  (x1-x2)^2              +  (y1-y2)             ^2 )^0.5
distpythagoras <- function(x1,y1,x2,y2) ( ((x1-x2)*1000*xmeter)^2 + ((y1-y2)*1000*ymeter)^2 )^0.5

distmeter(-83.001,42,-83,42)
#[1] 82.85069
distpythagoras(-83.001,42,-83,42)
#[1] 82.85069
distmeter(-83,42.001,-83,42)
#[1] 110.9713
distpythagoras(-83,42.001,-83,42)
#[1] 110.9713

buildingsAGM = buildingsAGG %>% 
               filter(size>0) %>%
               mutate(xdiff=(east-west)*1000,ydiff=(north-south)*1000) %>%
               mutate(xsize=xdiff*xmeter,ysize=ydiff*ymeter) %>%
               mutate(size=xsize*ysize) %>%
               select(building,size, xsize,ysize, n,north,south,west,east)

summary(buildingsAGM$xsize)
summary(buildingsAGM$ysize)
xepsilon = median(buildingsAGM$xsize) # 33.14028
yepsilon = median(buildingsAGM$ysize) # 35.09945

# many huge buildings:
buildingsAGM %>% filter(size>0) %>% arrange(desc(size)) %>% select(building,xsize,ysize) %>% slice(1:100) %>% print.default





# so we loop along all houses and check, if distance to next is smaller than 34m


buildings$same = FALSE
buildings$dist = NA
imax = length(buildings$building)

#calcdist <- function(i) { 
#    x1=buildings$lon[i-1]
#    x2=buildings$lon[i]
#    y1=buildings$lat[i-1]
#    y2=buildings$lat[i] 
#    d=distmeter(x1,y1,x2,y2) 
#    buildings$dist[i] <- d
#    buildings$same[i] <- d < 1156 # 34^2 
#    }

#calcdist2 <- function(i) { 
#    x1=buildings$lon[i-1]
#    x2=buildings$lon[i]
#    y1=buildings$lat[i-1]
#    y2=buildings$lat[i] 
#    d=distpythagoras(x1,y1,x2,y2) 
#    buildings$dist[i] <- d
#    buildings$same[i] <- d < 34 
#    }

#tic(); for (i in 2:1000) calcdist(i); toc()
## 5.62
#tic(); for (i in 2:1000) calcdist2(i); toc()
## 6.12
## incredibly slow!

#tic(); 
#   buildings$dist=mapply(distpythagoras,buildings$prevlon,buildings$prevlat,buildings$lon,buildings$lat)
#   summary(buildings$dist)
#   buildings$same <- buildings$dist < 34
#   summary(buildings$same)
#toc() # 4.136

#tic(); 
#   buildings$dist=mapply(distmeter,buildings$prevlon,buildings$prevlat,buildings$lon,buildings$lat)
#   summary(buildings$dist)
#   buildings$same <- buildings$dist < 34
#   summary(buildings$same)
#toc() # 20.184

preparelag <- function(){
   imax = length(buildings$building)
   buildings$close   <<- FALSE
   buildings$prevlon <<- 0
   buildings$prevlat <<- 0
   buildings$prevlat[2:imax]  <<- buildings$lat[1:(imax-1)]
   buildings$prevlon[2:imax]  <<- buildings$lon[1:(imax-1)]
   buildings$prevaddr[2:imax] <<- buildings$building[1:(imax-1)]
   buildings$prevlon[1]  <<- buildings$lon[1]
   buildings$prevlat[1]  <<- buildings$lat[1]
   buildings$prevaddr[1] <<-buildings$building[1]
}

checkforsameadress <- function(epsilon){
   preparelag()
   buildings$dist <<- distpythagoras(buildings$prevlon,buildings$prevlat,buildings$lon,buildings$lat)
   buildings$close <<- (buildings$dist < epsilon)
   r= c(epsilon,
        length(buildings$dist[buildings$close & (buildings$building == buildings$prevaddr)]),
        length(buildings$dist[buildings$close & (buildings$building != buildings$prevaddr)]))
   names(r)<-c("radius[m]","same_address","different_address")
   return(r)
}

######################## TODO: double check tests for correct work

# buildings which are close to other house but differ in address (sorted along latitude):
buildings <- buildings %>% arrange(lon)
preparelag()
data.frame(t(sapply(c(1024,512,256,128,64,32,16,8,4,2,1),checkforsameadress)))
buildings %>% filter(building==prevaddr) %>% filter(lat==prevlat) %>% filter(lon==prevlon) %>% nrow

# buildings which are close to other house but differ in address (sorted along latitude):
buildings <- buildings %>% arrange(lat)
preparelag()
buildings %>% filter(building==prevaddr) %>% filter(lat==prevlat) %>% filter(lon==prevlon) %>% nrow
data.frame(t(sapply(c(1024,512,256,128,64,32,16,8,4,2,1),checkforsameadress)))

# buildings which are close to other house but differ in address:
checksame(34)
summary(buildings$close)
summary(buildings$dist[buildings$close])
summary(buildings$dist[!buildings$close])
buildings %>% filter(same) %>% filter(building != prevaddr) %>% head(20)


############### reverse lookup

# bounding box with size of median size around each house
xmed = buildingsAGM %>% filter(size>0) %>% arrange(desc(size)) %>% select(xsize) %>% summarise(median(xsize))
xmed=as.double(xmed)
xmed #=> 33.14 
xe =((xmed/2)/xmeter)/1000
xe
ymed = buildingsAGM %>% filter(size>0) %>% arrange(desc(size)) %>% select(ysize) %>% summarise(median(ysize))
ymed=as.double(ymed)
ymed #=> 44.39
ye =((ymed/2)/ymeter)/1000
ye

buildingsREVERS = buildingsSUBMIT %>% 
                  mutate(south = lat - ye, north = lat + ye) %>%
                  mutate(west = lon - xe, east = lon + xe) %>% select(building,north,south,west,east)
                  
x = -83.20592
y = 42.36936

lookupBuilding <- function(x,y){
	return(buildingsREVERS %>% filter(south <= y & y <= north & west <=x & x<= east))
}
lookupBuilding(-83.20592,42.36936)
