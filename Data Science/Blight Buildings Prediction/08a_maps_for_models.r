require(ggmap)
map <- readRDS("maps/openstreetmap_detroit_zoom12.rds")

## slow!
p <- ggmap(map)+stat_density2d(data=violationsR, aes(x = lon, y = lat, fill = ..level.., alpha = 0.01),size = 0, geom = 'polygon')
ggsave("maps/density_violations.png", p, width=14, height=10, units="in")
p <- ggmap(map)+stat_density2d(data=crimes, aes(x = lon, y = lat, fill = ..level.., alpha = 0.1),size = 0, geom = 'polygon')
ggsave("maps/density_crimes.png", p, width=14, height=10, units="in")
p <- ggmap(map)+stat_density2d(data=calls, aes(x = lon, y = lat, fill = ..level.., alpha = 0.1),size = 0, geom = 'polygon')
ggsave("maps/density_calls.png", p, width=14, height=10, units="in")
p <- ggmap(map)+stat_density2d(data=permitsR, aes(x = lon, y = lat, fill = ..level.., alpha = 0.1),size = 0, geom = 'polygon')
ggsave("maps/density_permits.png", p, width=14, height=10, units="in")


p <- ggmap(map)
p <- p + geom_point(data=modeldata, aes(x=lon, y=lat, size=count, colour=count, alpha=count))
p <- p + scale_colour_gradientn(colors=c("blue","green","yellow","orange","red"))
p <- p + scale_alpha(range = c(0.1,1), guide = FALSE)
p <- p + scale_size(range = c(0.1,10), guide = FALSE)
p
ggsave("maps/modeldata_count.png", p, width=14, height=10, units="in")

p <- ggmap(map)
p <- p + geom_point(data=modeldata, aes(x=lon, y=lat, size=count, colour=label), alpha=0.1)
p <- p + scale_colour_gradientn(colors=c("blue","red"),
                                guide = guide_legend(title="Blight label",reverse = TRUE, override.aes = list(alpha = 1)),
                                breaks=c(0,1))
p <- p + scale_size(range = c(0.1,10), guide = FALSE)
p <- p + guides(fill = guide_legend(reverse = FALSE, override.aes = list(alpha = 1)))
p
ggsave("maps/modeldata_label.png", p, width=14, height=10, units="in")
