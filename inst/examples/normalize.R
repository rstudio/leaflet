library(leaflet)
library(sp)

## Create different forms of point data ==========

# Individual lng/lat vectors
lng <- runif(20)
lat <- runif(20)
# Simple matrix
mtx <- cbind(lng, lat)
# Spatial
pts <- sp::SpatialPoints(mtx)
ptsdf <- sp::SpatialPointsDataFrame(pts, data.frame(1:20))
# Data frame with standard col names
data <- data.frame(Longitude=lng, Latitude=lat, X=1:20)
# Data frame with weird col names
dataWeird <- data.frame(LngCol = lng, LatCol = lat, X=1:20)

# Make some circles, without formulas
leaflet() %>% addCircles(cbind(lng, lat))
leaflet() %>% addCircles(pts)
leaflet() %>% addCircles(ptsdf)
leaflet(data) %>% addCircles()
leaflet(data) %>% addCircles(c("Longitude", "Latitude"))
leaflet() %>% addCircles(data = data)
leaflet(dataWeird) %>% addCircles(c("LngCol", "LatCol"))

# Make some circles, with formulas
leaflet(data) %>% addCircles(Longitude ~ Latitude)
leaflet(dataWeird) %>% addCircles(LngCol ~ LatCol)
leaflet(dataWeird) %>% addCircles(~cbind(LngCol, LatCol))
leaflet(dataWeird) %>% addCircles(~data.frame(longitude = LngCol, latitude = LatCol))
