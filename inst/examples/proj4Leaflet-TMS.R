library(mapview) # for the popupTables
library(sp)

#' ## Leaflet Example of using EPSG:28892 Projection
#'

proj4def.4326 <- "+proj=longlat +datum=WGS84 +no_defs"
proj4def.28992 <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +no_defs"

data(meuse)
coordinates(meuse) <- ~x + y
proj4string(meuse) <- proj4def.28992
meuse.4326 <- spTransform(meuse, proj4def.4326)


#' ### Map + Markers in the Default Spherical Mercator
#' Just to verify that everything is correct in 4326
leaflet() %>% addTiles() %>%
  addCircleMarkers(data = meuse.4326)


#' ### Now in EPSG:28992

minZoom <- 0
maxZoom <- 13
resolutions <- c(3440.640, 1720.320, 860.160, 430.080, 215.040, 107.520, 53.760, 26.880, 13.440, 6.720, 3.360, 1.680, 0.840, 0.420)
bounds <- list(c(-285401.92, 22598.08), c(595401.9199999999, 903401.9199999999))
origin <- c(-285401.92, 22598.08)

crs.epsg28992 <- leafletCRS(crsClass = "L.Proj.CRS", code = "EPSG:28992",
                        proj4def = proj4def.28992,
                        resolutions = resolutions,
                        bounds = bounds,
                        origin = origin)

leaflet(options = leafletOptions(
  crs = crs.epsg28992, minZoom = 0, maxZoom = 13)) %>%
  addTiles("http://geodata.nationaalgeoregister.nl/tms/1.0.0/brtachtergrondkaart/{z}/{x}/{y}.png",
           options = tileOptions(tms = TRUE,
                                 errorTileUrl = "http://www.webmapper.net/theme/img/missing-tile.png"),
           attribution = "Map data: <a href=\"http://www.kadaster.nl\">Kadaster</a>") %>%
  addCircleMarkers(data = meuse.4326, popup = popupTable(meuse))


#' ## Korean TMS Provider

#' ### Map + Markers in the Default Spherical Mercator
#' Just to verify that everything is correct in 4326
leaflet() %>%
  addTiles() %>%
  addMarkers(126.615810, 35.925937, label = "Gunsan Airpoirt",
             labelOptions = labelOptions(noHide = TRUE))

#' ### Now with EPSG 5181 Projection

crs.epsg5181 <- leafletCRS(
  crsClass = "L.Proj.CRS",
  code = "EPSG:5181",
  proj4def = "+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
  resolutions = c(2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 0.5, 0.25),
  origin = c(-30000, -60000),
  bounds = list(c(-30000, -60000), c(494288, 464288))
  )

map <- leaflet(options = leafletOptions(
  crs = crs.epsg5181,
  continuousWorld = TRUE,
  worldCopyJump = FALSE
))

map %>%
  addTiles(
    urlTemplate = "http://i{s}.maps.daum-img.net/map/image/G03/i/1.20/L{z}/{y}/{x}.png",
    attribution = "ⓒ Daum",
    options = tileOptions(
    maxZoom = 14,
    minZoom = 0,
    zoomReverse = TRUE,
    subdomains = "0123",
    continuousWorld = TRUE,
    tms = TRUE
  )) %>%
  addMarkers(126.615810, 35.925937, label = "Gunsan Airpoirt",
             labelOptions = labelOptions(noHide = TRUE))
