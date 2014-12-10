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
ptsdf <- sp::SpatialPointsDataFrame(pts, data.frame(Color = topo.colors(20, NULL)))
# Data frame with standard col names
data <- data.frame(Longitude=lng, Latitude=lat, X=1:20)
# Data frame with weird col names
dataWeird <- data.frame(LngCol = lng, LatCol = lat, X=1:20)

# Make some circles, without formulas
leaflet() %>% addCircles(lng, lat)
leaflet() %>% addCircles(data = pts)
leaflet() %>% addCircles(data = ptsdf)
leaflet() %>% addCircles(data = ptsdf, radius = 4000, fillColor = ~Color)
leaflet(data) %>% addCircles()
leaflet() %>% addCircles(data = data)

# Make some circles, with formulas
leaflet(data) %>% addCircles(~Longitude, ~Latitude)
leaflet(dataWeird) %>% addCircles(~LngCol, ~LatCol)
leaflet() %>% addCircles(~LngCol, ~LatCol, data = dataWeird)

# Recycling of lng/lat is valid (should it be??)
leaflet() %>% addTiles() %>% addCircles(c(1,2), sort(runif(20) + 10))
# Plotting of empty data is OK
leaflet(data.frame(Latitude=numeric(0), Longitude=numeric(0))) %>% addCircles()
leaflet() %>% addCircles(numeric(0), numeric(0))

# Error cases
leaflet() %>% addCircles()    # No data at all
leaflet() %>% addCircles(NULL, NULL) # Explicit NULL
leaflet() %>% addCircles(NULL, 1) # Explicit NULL longitude
leaflet() %>% addCircles(1, NULL) # Explicit NULL latitude
nolat <- NULL
# Indirect NULL. It'd be OK for lat to be missing, but not for it to be present
# and NULL.
leaflet(data) %>% addCircles(1, nolat)

# Some polygon data
plng <- list(runif(3) + 1, runif(3) + 2, runif(3) + 3)
plat <- list(runif(3), runif(3), runif(3))
pdata <- data.frame(Latitude=I(plat), Longitude=I(plng))
leaflet(pdata) %>% addTiles() %>% addPolygons(~Longitude, ~Latitude)
