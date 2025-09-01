#' ---
#' title: "Leaflet + Proj4Leaflet"
#' ---
library(leaflet)

#' Default SPherical Mercator Projection specified explicitly
leaflet(
  options =
    leafletOptions(crs = leafletCRS(crsClass = "L.CRS.EPSG3857"))) %>%
  addTiles()

#' <br/><br/>Gothenberg, Sweeden in default projection
leaflet() %>%
  addTiles() %>%
  setView(11.965, 57.704, 16)


#' <br/><br/>Gothenberg, Sweeden in local projection
leaflet(
  options =
    leafletOptions(
      crs = leafletCRS(
        crsClass = "L.Proj.CRS",
        code = "EPSG:3006",
        proj4def = "+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
        resolutions = c(
          8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 0.5 ),
        origin = c(0, 0)
        )
      )) %>%
  addTiles(
    urlTemplate = "https://api.geosition.com/tile/osm-bright-3006/{z}/{x}/{y}.png",
    attribution = "Map data &copy; <a href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\">OpenStreetMap contributors</a>, Imagery &copy; 2013 <a href=\"http://www.kartena.se/\" target=\"_blank\">Kartena</a>",
    options = tileOptions(minZoom = 0, maxZoom = 14)) %>%
  setView(11.965, 57.704, 13)

#' <br/><br/>
#' ## Mollweide Projection
#' The code is adaptation of [this](https://github.com/turban/Leaflet.Graticule/blob/master/examples/mollweide.html).
library(sp)
srcURL <- "https://cdn.rawgit.com/turban/Leaflet.Graticule/master/examples/lib/countries-110m.js"
v8 <- V8::v8()
v8$source(srcURL)
geoJSON <- geojsonio::as.json(v8$get("countries"))
spdf <- geojsonio::geojson_sp(geoJSON)
sp::proj4string(spdf) # We need our data to be in WGS84 a.k.a EPSG4326 i.e. just latlong

# Leaflet will project the polygons/lines/markers to the target CRS before it maps them.
leaflet(options =
          leafletOptions(maxZoom = 5,
               crs = leafletCRS(crsClass = "L.Proj.CRS", code = "ESRI:53009",
                        proj4def = "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +a=6371000 +b=6371000 +units=m +no_defs",
                        resolutions = c(65536, 32768, 16384, 8192, 4096, 2048)
                       ))) %>%
  addGraticule(style = list(color = "#999", weight = 0.5, opacity = 1)) %>%
  addGraticule(sphere = TRUE, style = list(color = "#777", weight = 1, opacity = 0.25)) %>%
  addPolygons(data = spdf, weight = 1, color = "#ff0000")

#' <br/><br/>L.CRS.Simple example.
#' For now the image is specified via onRender and native JS call
#' because we haven't coded the L.ImageLayer part yet.
bounds <- c(-26.5, -25, 1021.5, 1023)
leaflet(options = leafletOptions(
  crs = leafletCRS(crsClass = "L.CRS.Simple"),
  minZoom = -5,
  maxZoom = 5)) %>%
  fitBounds(bounds[1], bounds[2], bounds[3], bounds[4]) %>%
  setMaxBounds(bounds[1], bounds[2], bounds[3], bounds[4]) %>%
  htmlwidgets::onRender("
  function(el, t) {
    var myMap = this;
    var bounds = myMap.getBounds();
    var image = new L.ImageOverlay(
                      'https://leafletjs.com/examples/crs-simple/uqm_map_full.png',
                      bounds);
    image.addTo(myMap);
  }")

#' <br/><br/> Albers USA with moved Alaska and Hawaii
#' with some fancy effects.
#' You need albersusa for this. `devtools::install_github('hrbrmstr/albersusa')`


library(sp)
library(albersusa) # requires rgdal and maptools (archived)
spdf <- rmapshaper::ms_simplify(usa_composite())
pal <- colorNumeric(
  palette = "Blues",
  domain = spdf@data$pop_2014
)

bounds <- c(-125, 24, -75, 45)

leaflet(
  options =
    leafletOptions(
      worldCopyJump = FALSE,
      crs = leafletCRS(
        crsClass = "L.Proj.CRS",
        code = "EPSG:2163",
        proj4def = "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs",
        resolutions = c(65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128)
      ))) %>%
  fitBounds(bounds[1], bounds[2], bounds[3], bounds[4]) %>%
  setMaxBounds(bounds[1], bounds[2], bounds[3], bounds[4]) %>%
  addPolygons(data = spdf, weight = 1, color = "#000000",
              fillColor = ~pal(pop_2014),
              fillOpacity = 0.7,
              label = ~stringr::str_c(name, " ", pop_2014),
              labelOptions = labelOptions(direction = "auto"),
              highlightOptions = highlightOptions(
                color = "#00ff00", opacity = 1, weight = 2, fillOpacity = 1,
                bringToFront = TRUE, sendToBack = TRUE) )
