library(leaflet)
library(sf)
library(sp)

expect_maps_equal <- function(m1, m2) {
  attr(m1$x, "leafletData") <- NULL
  attr(m2$x, "leafletData") <- NULL
  expect_equal(m1, m2)
}

### polygons --------------------------------------------------------------

pgontest <- function(x) {
  cat(class(x), "\n")
  leaflet(x) %>% addTiles() %>% addPolygons()
}

gadmCHE <- readRDS(system.file("extdata", "gadmCHE.rds", package = "leaflet"))
poldata <- st_as_sf(gadmCHE)

(r1 <- pgontest(poldata))
(r2 <- pgontest(st_geometry(poldata)))
(r3 <- pgontest(st_geometry(poldata)[[1]]))
(r4 <- pgontest(st_geometry(poldata)[[1]][[1]] %>% st_polygon()))
(r5 <- pgontest(gadmCHE))
(r6 <- pgontest(polygons(gadmCHE)))
(r7 <- pgontest(polygons(gadmCHE)@polygons[[1]]))
(r8 <- pgontest(polygons(gadmCHE)@polygons[[1]]@Polygons[[1]]))

expect_maps_equal(r1, r2)
expect_maps_equal(r3, r4)
expect_maps_equal(r1, r5)

### lines -----------------------------------------------------------------

atlStorms2005 <- readRDS(system.file("extdata", "atlStorms2005.rds", package = "leaflet"))
lindata <- st_as_sf(atlStorms2005)

plinetest <- function(x) {
  cat(class(x), "\n")
  leaflet(x) %>% addTiles() %>% addPolylines()
}

(l1 <- plinetest(lindata))  # sf, data.frame
(l2 <- plinetest(st_geometry(lindata)))  # sfc_LINESTRING, sfc
(l3 <- plinetest(st_geometry(lindata)[[1]]))  # XY, LINESTRING, sfg
(l4 <- plinetest(st_multilinestring(st_geometry(lindata))))  # XY, MULTILINESTRING, sfg
(l5 <- plinetest(atlStorms2005))
(l6 <- plinetest(SpatialLines(atlStorms2005@lines)))
(l7 <- plinetest(atlStorms2005@lines[[1]]))
(l8 <- plinetest(atlStorms2005@lines[[1]]@Lines[[1]]))

expect_maps_equal(l1, l2)
expect_maps_equal(l1, l5)
expect_maps_equal(l1, l6)
expect_maps_equal(l3, l7)
expect_maps_equal(l3, l8)

### points ----------------------------------------------------------------
breweries91 <- readRDS(system.file("extdata", "breweries91.rds", package = "leaflet"))
ptsdata <- st_as_sf(breweries91)
class(ptsdata)  # sf, data.frame
class(st_geometry(ptsdata))  # sfc_POINT, sfc
class(st_geometry(ptsdata)[[1]])  # XY, POINT, sfg
class(do.call(rbind, unclass(st_geometry(ptsdata))) %>% st_multipoint())  # XY, POINT, sfg

(p1 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = ptsdata))
(p2 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = st_geometry(ptsdata)))
(p3 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = st_geometry(ptsdata)[[1]]))
# leaflet() %>% addTiles() %>% addCircleMarkers(data = do.call(rbind, unclass(st_geometry(ptsdata))) %>% st_multipoint())

expect_maps_equal(p1, p2)
