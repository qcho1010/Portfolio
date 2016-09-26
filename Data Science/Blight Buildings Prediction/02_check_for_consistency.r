
######################## count empty cells

nrow(calls[is.na(calls$issue_type),])
nrow(calls[is.na(calls$image),])
nrow(calls[!is.na(calls$image),])
nrow(calls)
summary(calls$image,maxsum=2)

nrow(crimes[is.na(crimes$LOCATION),])
nrow(crimes[is.na(crimes$LAT),])
nrow(crimes[is.na(crimes$LON),])
nrow(crimes[is.na(crimes$lat),])
nrow(crimes[is.na(crimes$lon),])
nrow(crimes[is.na(crimes$LON) & is.na(crimes$lon),])
nrow(crimes[is.na(crimes$LAT) & is.na(crimes$lat),])

nrow(calls[is.na(calls$lng),])
nrow(calls[is.na(calls$lat),])

nrow(permits[is.na(permits$lat),])
#[1] 817
nrow(permits[is.na(permits$lon),])
#[1] 817
nrow(permits)
#[1] 7133
nrow(permits[is.na(permits$geom),])
#[1] 7092
nrow(permits[!is.na(permits$geom),])
#[1] 41
nrow(permits[is.na(permits$site_location),])
#[1] 803
nrow(permits[is.na(permits$SITE_ADDRESS),])
#[1] 0

nrow(violations[is.na(violations$lat),])
#[1] 0
nrow(violations[is.na(violations$lon),])
#[1] 0

################## check for consistancy of redundant information

require(dplyr)

# site_location should be checked against geom
permits$geomlat <- as.double(sub("\\((-?[0-9.]+).*,.*","\\1",permits$geom,perl=TRUE, useBytes = TRUE))
permits$geomlon <- as.double(sub(".*, *(-?[0-9.]*)\\)","\\1",permits$geom,perl=TRUE, useBytes = TRUE))
nrow(permits[!is.na(permits$geomlat),])
nrow(permits[!is.na(permits$geomlon),])
permits %>% filter(!is.na(geomlat)) %>% transmute(diff=lat-geomlat) -> d; mean(d$diff)
#[1] 0    => zero difference
permits %>% filter(!is.na(geomlon)) %>% transmute(diff=lon-geomlon) -> d; mean(d$diff)
#[1] 0    => zero difference
permits %>% filter(!is.na(geomlon)) %>% filter(!is.na(lon)) %>% nrow
#[1] 41   => very few cases
permits %>% filter(!is.na(geomlat)) %>% filter(!is.na(lat)) %>% nrow
#[1] 41   => very few cases
permits %>% filter(!is.na(geomlon)) %>% filter(is.na(lon)) %>% nrow
#[1] 0    => geom gives no additional information
permits %>% filter(!is.na(geomlat)) %>% filter(is.na(lat)) %>% nrow
#[1] 0    => geom gives no additional information

# LON,LAT should be checked against lon,lat
crimes %>% transmute(diff = lon -  LON) %>% filter(diff>0) -> d; mean(d$diff)
#[1] 0.0001732128    =>  < 0.0004 => 40m
crimes %>% transmute(diff = lat -  LAT) %>% filter(diff>0) -> d; mean(d$diff)
#[1] 0.001144984
crimes %>% transmute(diff = lat -  LAT) %>% filter(diff>0) %>% filter(diff <1) -> d; mean(d$diff)
#[1] 0.0001725768   =>  < 0.0004 => 40m
crimes %>% transmute(diff = lat -  LAT) %>% filter(diff>=1) %>% nrow
#[1] 5  => five buildings with diff > 1
   
# lng,lat should be checked against location
calls$LAT <- as.double(sub("\\((-?[0-9.]+).*,.*","\\1",calls$location,perl=TRUE, useBytes = TRUE))
calls$LON <- as.double(sub(".*, *(-?[0-9.]*)\\)","\\1",calls$location,perl=TRUE, useBytes = TRUE))
calls %>% transmute(diff = lon -  LON) %>% filter(diff>0) -> d; mean(d$diff)
#[1] 2.473782e-11
calls %>% transmute(diff = lat -  LAT) %>% filter(diff>0) -> d; mean(d$diff)
#[1] 2.614052e-11

# ViolationStreetNumber ViolationStreetName should be checked against location
violations$ADDRESS <- trimws(toupper(sub("(.*?)\n.*","\\1",violations$ViolationAddress)))
violations %>% select(ADDRESS,building) %>% nrow
#[1] 307801
violations %>% select(ADDRESS,building) %>% filter(ADDRESS != building) %>% nrow
#[1] 17035
# locations where ADDRESS only partly matches explicite violation street and number:
violations %>% select(ADDRESS,building) %>% filter(ADDRESS != building) %>% mutate(match = charmatch(ADDRESS,building,nomatch=-1)) %>% filter(match<0) %>% nrow
#[1] 0

