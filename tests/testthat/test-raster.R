
expect_maps_equal <- function(m1, m2) {
  attr(m1$x, "leafletData") <- NULL
  attr(m2$x, "leafletData") <- NULL
  expect_equal(m1, m2, ignore_function_env = TRUE, ignore_formula_env = TRUE)
}

# Some proj4string values differ only by one having whole numbers represented as
# x while others have x.0. So, strip each trailing .0 value.
normalize_zero_values <- function(str) {
  gsub("=(\\d+).0( |$)", "=\\1\\2", str)
}

test_that("rasters", {
  skip_if_not_installed("terra")

  library(terra)
  library(raster)

  lux <- rast(system.file("ex/elev.tif", package="terra"))
  pmerc <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m +nadgrids=@null +wktext +no_defs"

  plux <- projectRasterForLeaflet(lux, "bilinear")
  expect_equal(normalize_zero_values(crs(plux, proj=TRUE)), pmerc)
  test <- projectRasterForLeaflet(raster(lux), "bilinear")
  expect_equal(normalize_zero_values(proj4string(test)), pmerc)

  # terra and raster have different projection algorithms, and while
  # their outputs are very similar, they are not identical. Hence we need
  # to use pre-projected rasters and project=FALSE
  rtest <- function(x) {
    leaflet() %>% addTiles() %>% addRasterImage(x, project=FALSE)
  }

  (r1 <- rtest(plux))
  (r2 <- rtest(raster(plux)))

  expect_maps_equal(r1, r2)

 # test with color map
  r <- rast(ncols=10, nrows=10, vals=rep_len(10:15, length.out=100), xmin=0, xmax=10^6, ymin=0, ymax=10^6, crs=pmerc)
  r[5,] <- NA
  coltab(r) <- c(rep("#FFFFFF", 10), rainbow(6, end=.9))
  (r3 <- rtest(r))

})

