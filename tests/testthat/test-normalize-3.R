
expect_maps_equal <- function(m1, m2) {
  attr(m1$x, "leafletData") <- NULL
  attr(m2$x, "leafletData") <- NULL
  expect_equal(m1, m2, ignore_function_env = TRUE, ignore_formula_env = TRUE)
}


test_that("normalize terra", {
  skip_if_not_installed("terra")
  skip_if_not_installed("sf")

  library(terra)
  library(sp)
  library(raster) # currently needed to go from Spatial -> vect

  ### polygons --------------------------------------------------------------

  pgontest <- function(x) {
    leaflet(x) %>% addTiles() %>% addPolygons()
  }

  poldata <- vect(gadmCHE)
  crs(poldata) <- "+proj=longlat +datum=WGS84"

  (r1 <- pgontest(poldata))
  (r2 <- pgontest(gadmCHE))

  expect_maps_equal(r1, r2)

  ### lines -----------------------------------------------------------------

  lindata <- vect(atlStorms2005)
  crs(lindata) <- "+proj=longlat +datum=WGS84"

  plinetest <- function(x) {
    leaflet(x) %>% addTiles() %>% addPolylines()
  }

  (l1 <- plinetest(lindata))  # terra, SpatVector
  (l2 <- plinetest(atlStorms2005))

  expect_maps_equal(l1, l2)

  ### points ----------------------------------------------------------------
  ptsdata <- vect(breweries91)
  crs(ptsdata) <- "+proj=longlat +datum=WGS84"

  (p1 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = ptsdata))
  (p2 <- leaflet() %>% addTiles() %>% addCircleMarkers(data = breweries91))
  expect_maps_equal(p1, p2)

  ### lines -----------------------------------------------------------------
  polys <-
    Polygons(list(
      create_square(),
      create_square(, 5, 5),
      create_square(1, hole = TRUE),
      create_square(1, 5, 5, hole = TRUE),
      create_square(0.4, 4.25, 4.25, hole = TRUE)
    ), "A")
  comment(polys) <- "0 0 1 2 2"

  spolys <- SpatialPolygons(list(
    polys
  ))
  # these "commented" Spatial objects need to go through
  # sf for terra to understand them properly
  vpolys = vect(sf::st_as_sf(spolys ))
  (l101 <- leaflet(spolys) %>% addPolygons())
  (l102 <- leaflet(vpolys) %>% addPolygons())
  expect_maps_equal(l101, l102)
  (l103 <- leaflet(spolys) %>% addPolylines())
  (l104 <- leaflet(vpolys) %>% addPolylines())
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
  vslines <- vect(slines)
  (l105 <- leaflet(slines) %>% addPolylines())
  (l106 <- leaflet(vslines) %>% addPolylines())
  expect_maps_equal(l105, l106)
})
