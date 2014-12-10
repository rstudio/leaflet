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
leaflet() %>% addCircles(lng, lat)
leaflet() %>% addCircles(data = pts)
leaflet() %>% addCircles(data = ptsdf)
leaflet(data) %>% addCircles()
leaflet() %>% addCircles(data = data)

# Make some circles, with formulas
leaflet(data) %>% addCircles(~Longitude, ~Latitude)
leaflet(dataWeird) %>% addCircles(~LngCol, ~LatCol)
leaflet() %>% addCircles(~LngCol, ~LatCol, data = dataWeird)
