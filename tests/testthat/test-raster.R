
expect_maps_equal <- function(m1, m2) {
  attr(m1$x, "leafletData") <- NULL
  attr(m2$x, "leafletData") <- NULL
  expect_equal(m1, m2, check.environment = FALSE)
}


test_that("rasters", {
  skip_if_not_installed("terra")

  library(terra)
  library(raster) 

  lux <- rast(system.file("ex/elev.tif", package="terra"))
  pmerc <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs"

  plux <- projectRasterForLeaflet(lux, "bilinear")
  expect_equal(crs(plux, proj=TRUE), pmerc)
  test <- projectRasterForLeaflet(raster(lux), "bilinear")
  expect_equal(proj4string(test), pmerc)

  # terra and raster have different projection algorithms, and while
  # their outputs are very similar, they are not identical. Hence we need 
  # to use pre-projected rasters and project=FALSE  
  rtest <- function(x) {
    leaflet() %>% addTiles() %>% addRasterImage(x, project=FALSE)
  }

  (r1 <- rtest(plux))
  (r2 <- rtest(raster(plux)))

  expect_maps_equal(r1, r2)

})
