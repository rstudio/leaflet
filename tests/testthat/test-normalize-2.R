
expect_maps_equal <- function(m1, m2) {
  attr(m1$x, "leafletData") <- NULL
  attr(m2$x, "leafletData") <- NULL
  expect_equal(m1, m2)
}

test_that("normalize", {
  skip_if_not_installed("sf")
  skip_if_not_installed("rgeos")

  library(sf)
  library(sp)

  ### polygons --------------------------------------------------------------

  pgontest <- function(x) {
    cat(class(x), "\n")
    leaflet(x) %>% addTiles() %>% addPolygons()
  }

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

  (p4 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = ptsdata[FALSE, ]))
  (p5 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = st_geometry(ptsdata)[FALSE]))
  (p6 <- leaflet() %>% addTiles() %>% addCircleMarkers(lng = numeric(0), lat = numeric(0)))
  expect_maps_equal(p4, p5)
  expect_maps_equal(p4, p6)

  ### lines -----------------------------------------------------------------
  create_square <- function(width = 2, lng = 0, lat = 0, hole = FALSE, type = Polygon) {
    lngs <- c(lng - width / 2, lng + width / 2, lng + width / 2, lng - width / 2)
    lats <- c(lat + width / 2, lat + width / 2, lat - width / 2, lat - width / 2)

    if (hole) {
      lngs <- rev(lngs)
      lats <- rev(lats)
    }

    type(cbind(lng = lngs, lat = lats))
  }

  spolys <- SpatialPolygons(list(
    Polygons(list(
      create_square(),
      create_square(, 5, 5),
      create_square(1, hole = TRUE),
      create_square(1, 5, 5, hole = TRUE),
      create_square(0.4, 4.25, 4.25, hole = TRUE)
    ), "A")
  ))
  stspolys <- st_as_sf(spolys)
  (l101 <- leaflet(spolys) %>% addPolygons())
  (l102 <- leaflet(stspolys) %>% addPolygons())
  expect_maps_equal(l101, l102)
  (l103 <- leaflet(spolys) %>% addPolylines())
  (l104 <- leaflet(stspolys) %>% addPolylines())
  expect_maps_equal(l103, l104)

  slines <- SpatialLines(list(
    Lines(list(
      create_square(type = Line),
      create_square(, 5, 5, type = Line),
      create_square(1, hole = TRUE, type = Line),
      create_square(1, 5, 5, hole = TRUE, type = Line),
      create_square(0.4, 4.25, 4.25, hole = TRUE, type = Line)
    ), "A")
  ))
  stslines <- st_as_sf(slines)
  (l105 <- leaflet(slines) %>% addPolylines())
  (l106 <- leaflet(stslines) %>% addPolylines())
  expect_maps_equal(l105, l106)
})
