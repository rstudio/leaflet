library(leaflet)
library(sp)
library(maps)

## Create different forms of point data ==========

# Individual lng/lat vectors
lng = runif(20)
lat = runif(20)
# Simple matrix
mtx = cbind(lng, lat)
# Spatial
pts = sp::SpatialPoints(mtx)
ptsdf = sp::SpatialPointsDataFrame(pts, data.frame(Color = topo.colors(20, NULL)))
# Data frame with standard col names
data = data.frame(Longitude=lng, Latitude=lat, X=1:20)
# Data frame with weird col names
dataWeird = data.frame(LngCol = lng, LatCol = lat, X=1:20)
# SpatialDataFrame with weird col names turned to coords
datacoord = dataWeird
coordinates(datacoord) = ~LngCol+LatCol

# Make some circles, without formulas
leaflet() %>% addCircles(lng, lat)
leaflet() %>% addCircles(data = pts)
leaflet() %>% addCircles(data = ptsdf)
leaflet() %>% addCircles(data = ptsdf, radius = 4000, fillColor = ~Color)
leaflet(data) %>% addCircles()
leaflet() %>% addCircles(data = data)
leaflet(datacoord) %>% addCircles()

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
nolat = NULL
# Indirect NULL. It'd be OK for lat to be missing, but not for it to be present
# and NULL.
leaflet(data) %>% addCircles(1, nolat)

# Some polygon data
rawpolys = list(
  lng = list(runif(3) + 1, runif(3) + 2, runif(3) + 3),
  lat = list(runif(3) + 12, runif(3) + 12, runif(3) + 12)
)
plng = c(rawpolys$lng[[1]], NA, rawpolys$lng[[2]], NA, rawpolys$lng[[3]])
plat = c(rawpolys$lat[[1]], NA, rawpolys$lat[[2]], NA, rawpolys$lat[[3]])
pdata = data.frame(Latitude=I(plat), Longitude=I(plng))
pgons = list(
  Polygons(list(Polygon(cbind(rawpolys$lng[[1]], rawpolys$lat[[1]]))), ID="A"),
  Polygons(list(Polygon(cbind(rawpolys$lng[[2]], rawpolys$lat[[2]]))), ID="B"),
  Polygons(list(Polygon(cbind(rawpolys$lng[[3]], rawpolys$lat[[3]]))), ID="C")
)
spgons = SpatialPolygons(pgons)
spgonsdf = SpatialPolygonsDataFrame(spgons, data.frame(Category = as.factor(1:3)), FALSE)

Sr1 = Polygon(cbind(c(2,4,4,1,2),c(2,3,5,4,2)))
Sr2 = Polygon(cbind(c(5,4,2,5),c(2,3,2,2)))
Sr3 = Polygon(cbind(c(4,4,5,10,4),c(5,3,2,5,5)))
Sr4 = Polygon(cbind(c(5,6,6,5,5),c(4,4,3,3,4)), hole = TRUE)
Srs1 = Polygons(list(Sr1), "s1")
Srs2 = Polygons(list(Sr2), "s2")
Srs3 = Polygons(list(Sr4, Sr3), "s3/4")
SpP = SpatialPolygons(list(Srs1,Srs2,Srs3), 1:3)

leaflet(pdata) %>% addTiles() %>% addPolygons(~Longitude, ~Latitude)
leaflet(pdata) %>% addTiles() %>% addPolygons(lng=plng, lat=plat)
leaflet(pdata) %>% addTiles() %>% addPolygons(data = cbind(plng, plat))
# Single Polygon
leaflet() %>% addPolygons(data = pgons[[2]]@Polygons[[1]])
# Single Polygons
leaflet() %>% addPolygons(data = pgons[[1]])
# SpatialPolygons
leaflet() %>% addTiles() %>% addPolygons(data = spgons)
# SpatialPolygonsDataFrame
leaflet() %>% addPolygons(data = spgonsdf)
leaflet() %>% addPolygons(data = SpP)
leaflet() %>% addPolygons(data = SpP, color = topo.colors(3, NULL), stroke = FALSE) %>%
  addPolygons(data = spgonsdf, color = 'blue', stroke = FALSE, fillOpacity = 0.5)
leaflet() %>% addPolylines(data = SpP)

leaflet(data = map("state", fill=TRUE, plot=FALSE)) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)
