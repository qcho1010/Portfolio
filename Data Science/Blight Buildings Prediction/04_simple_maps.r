

################## maps
#
# install.packages("gtable")
# install.packages("munsell")
# install.packages("sp")
# install.packages("ggmap")    # dependencies broken!

require(ggmap)

# location: an address, longitude/latitude pair (in that order), or left/bottom/right/top bounding box

# get_openstreetmap(bbox = c(left = -95.80204, bottom = 29.38048, right = -94.92313, top = 30.14344)

detroit=c(-83.3,42.225,-82.9,42.475)
map12<-get_map(location=detroit,filename="maps/ggmapTemp.png",zoom=12,source="osm",maptype = "roadmap", color = "bw")
saveRDS(map12,"maps/openstreetmap_detroit_zoom12.rds")

map <- readRDS("maps/openstreetmap_detroit_zoom12.rds")

p <- ggmap(map)
p <- p + geom_point(data=permits, aes(x=lon, y=lat), color = "red", alpha=0.1)
ggsave("maps/permits.png", p, width=14, height=10, units="in")

p <- ggmap(map)
p <- p + geom_point(data=calls, aes(x=lon, y=lat), color = "green", alpha=0.05)
ggsave("maps/calls.png", p, width=14, height=10, units="in")

p <- ggmap(map)
p <- p + geom_point(data=crimes, aes(x=lon, y=lat), color = "orange", alpha=0.02)
ggsave("maps/crimes.png", p, width=14, height=10, units="in")

p <- ggmap(map)
p <- p + geom_point(data=violations, aes(x=lon, y=lat), color = "blue", alpha=0.01)
ggsave("maps/violations.png", p, width=14, height=10, units="in")


p <- ggmap(map)
p <- p + geom_point(data=violations, aes(x=lon, y=lat), color = "blue", alpha=0.01)
p <- p + geom_point(data=calls, aes(x=lon, y=lat), color = "green", alpha=0.05)
p <- p + geom_point(data=crimes, aes(x=lon, y=lat), color = "orange", alpha=0.02)
p <- p + geom_point(data=permits, aes(x=lon, y=lat), color = "red", alpha=0.1)
ggsave("maps/combined.png", p, width=14, height=10, units="in")
