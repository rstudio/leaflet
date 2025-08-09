#' ---
#' title: "Polar Maps in Leaflet"
#' author: "Bhaskar V. Karambelkar"
#' ---

library(leaflet)

#' ## Artic Projections

#' There is a [polarmap.js](http://webmap.arcticconnect.ca/)
#' leaflet plugin available, but that one is not easy to integrate in to the R package.<br/>
#' But thankfully it does provide Tiles in different projections
#' which can be used with Proj4Leaflet.
#' In all it supports 6 projections and corresponding tile layers.
#' <br/>
#' The polarmap.js supports only Artic data, for Antartica see the end of this document.


#' All these numbers and calculations come from the polarmap.js plugin, specifically from these files
#'
#' - http://webmap.arcticconnect.ca/polarmap.js/dist/polarmap-src.js
#' - http://webmap.arcticconnect.ca/tiles.html
#' - http://webmap.arcticconnect.ca/usage.html
#'
extent <- 11000000 + 9036842.762 + 667
origin <- c(-extent, extent)
maxResolution <- (extent - -extent) / 256
defZoom <- 4
bounds <- list(c(-extent, extent), c(extent, -extent))
minZoom <- 0
maxZoom <- 18
resolutions <- purrr::map_dbl(minZoom:maxZoom, function(x) maxResolution / (2 ^ x))

# 6 Projection EPSG Codes
projections <- c("3571", "3572", "3573", "3574", "3575", "3576")
# Corresponding proj4defs codes for each projection
proj4defs <- list(
  "3571" = "+proj=laea +lat_0=90 +lon_0=180 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  "3572" = "+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  "3573" = "+proj=laea +lat_0=90 +lon_0=-100 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  "3574" = "+proj=laea +lat_0=90 +lon_0=-40 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  "3575" = "+proj=laea +lat_0=90 +lon_0=10 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  "3576" = "+proj=laea +lat_0=90 +lon_0=90 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
)

# create a CRS instance for each projection
crses <- purrr::map(projections, function(code) {
  leafletCRS(
    crsClass = "L.Proj.CRS",
    code = sprintf("EPSG:%s", code),
    proj4def = proj4defs[[code]],
    origin = origin,
    resolutions = resolutions,
    bounds = bounds
  )
})

# Tile URL Template for each projection
tileURLtemplates <- purrr::map(projections, function(code) {
  sprintf("https://tiles.arcticconnect.ca/osm_%s/{z}/{x}/{y}.png",
          code)
})

# We can't add all 6 tiles to our leaflet map,
# because each one is in a different projection,
# and you can have only one projection per map in Leaflet.
# So we create 6 maps.
polarmaps <- purrr::map2(crses, tileURLtemplates,
    function(crs, tileURLTemplate) {
      leaflet(options = leafletOptions(
        crs = crs, minZoom = minZoom, maxZoom = maxZoom)) %>%
        setView(0, 90, defZoom) %>%
        addTiles(urlTemplate = tileURLTemplate,
          attribution = "Map © ArcticConnect. Data © OpenStreetMap contributors",
          options = tileOptions(subdomains = "abc", noWrap = TRUE,
                      continuousWorld = FALSE, detectRetina = TRUE))
    })

#' #### EPSG:3571
polarmaps[[1]] %>%
  addGraticule()

#' #### EPSG:3572
polarmaps[[2]]

#' #### EPSG:3573
polarmaps[[3]]

#' #### EPSG:3574
polarmaps[[4]]

#' #### EPSG:3575
polarmaps[[5]]

#' #### EPSG:3576
polarmaps[[6]]

#' ## Antartica
#' Code adapted from
#' https://github.com/nasa-gibs/gibs-web-examples/blob/release/examples/leaflet/antarctic-epsg3031.js <br/>

resolutions <- c(8192, 4096, 2048, 1024, 512, 256)
zoom <- 0
maxZoom <- 5

border <- geojsonio::geojson_read(system.file("examples/Seamask_medium_res_polygon.kml", package = "leaflet"), what = "sp")
points <-  geojsonio::geojson_read(system.file("examples/Historic_sites_and_monuments_point.kml", package = "leaflet"), what = "sp")

crsAntartica <-  leafletCRS(
  crsClass = "L.Proj.CRS",
  code = "EPSG:3031",
  proj4def = "+proj=stere +lat_0=-90 +lat_ts=-71 +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs",
  resolutions = resolutions,
  origin = c(-4194304, 4194304),
  bounds =  list( c(-4194304, -4194304), c(4194304, 4194304) )
)

antarticaTilesURL <- "https://map1{s}.vis.earthdata.nasa.gov/wmts-antarctic/MODIS_Aqua_CorrectedReflectance_TrueColor/default/2014-12-01/EPSG3031_250m/{z}/{y}/{x}.jpg"

leaflet(options = leafletOptions(
  crs = crsAntartica, minZoom = zoom, maxZoom = maxZoom, worldCopyJump = FALSE)) %>%
  setView(0, -90, 0) %>%
  addPolygons(data = border, color = "#ff0000", weight = 2, fill = FALSE) %>%
  addCircleMarkers(data = points, label = ~Name) %>%
  addTiles(urlTemplate = antarticaTilesURL,
           layerId = "antartica_tiles",
           attribution = paste(
             "<a href='https://earthdata.nasa.gov/gibs' target='_blank'> NASA EOSDIS GIBS</a>&nbsp;&nbsp;&nbsp;",
             "<a href='https://github.com/nasa-gibs/web-examples/blob/release/leaflet/js/antarctic-epsg3031.js'  target='_blank'> View Source </a>"
             ),
           options = tileOptions(
             tileSize = 512,
             subdomains = "abc",
             noWrap = TRUE,
             continuousWorld = TRUE,
             format = "image%2Fjpeg"
           )) %>%
  addGraticule() %>%
  htmlwidgets::onRender(
    "function(el, t){
       var myMap = this;
       debugger;
       var tileLayer = myMap.layerManager._byLayerId['tile\\nantartica_tiles'];

       // HACK: BEGIN
       // Leaflet does not yet handle these kind of projections nicely. Monkey
       // patch the getTileUrl function to ensure requests are within
       // tile matrix set boundaries.
       var superGetTileUrl = tileLayer.getTileUrl;

       tileLayer.getTileUrl = function(coords) {
         debugger;
         var max = Math.pow(2, tileLayer._getZoomForUrl() + 1);
         if ( coords.x < 0 ) { return ''; }
         if ( coords.y < 0 ) { return ''; }
         if ( coords.x >= max ) { return ''; }
         if ( coords.y >= max ) { return ''; }
           return superGetTileUrl.call(tileLayer, coords);
       };
       // HACK: END
    }")
