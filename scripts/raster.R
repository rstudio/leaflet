library(raster)
r <- raster(xmn = -110, xmx = -90, ymn = 40, ymx = 60, ncols = 40, nrows = 40)
r <- setValues(r, 1:ncell(r))
projection(r)
# proj.4 projection description
newproj <- "+proj=lcc +lat_1=48 +lat_2=33 +lon_0=-100 +ellps=WGS84"

#simplest approach
pr1 <- projectRaster(r, crs = newproj)

prb <- projectRaster(r, pr1, method = "bilinear")
invb <- projectRaster(prb, r, method = "bilinear")

prn <- projectRaster(r, pr1, method = "ngb")
invn <- projectRaster(prn, r, method = "ngb")


par(mfrow = c(1, 2))
plot(r - invb)
plot(r - invn)



r <- raster(xmn = -60, xmx = -25, ymn = 70, ymx = 81, nrows = 30, ncols = 30)
set.seed(0)
values(r) <- matrix(sample(1:5, 900, replace = TRUE), nrow(r), ncol(r), byrow = TRUE)
l <- function(method = "auto") {
  leaflet() %>%
    addTiles() %>%
    addRasterImage(r, colors = "Spectral", opacity = 0.8, method = method) %>%
    addMeasure() %>%
    addLegend(
      title = paste0("Raster\nMethod: ", method),
      pal = rasterLegendColor("Spectral", r),
      values = values(r)
    )
}
l()
a <- l("bilinear")
l("ngb")
r <- as.factor(r)
l("bilinear")
l("ngb")
