#'
#' An example to show how to highlight polygons on hover using `onRender`
#'
library(sp)
library(albersusa) # Requires rgdal / rgeos archived.
library(leaflet)

spdf <- rmapshaper::ms_simplify(usa_composite())

pal <- colorNumeric(palette = "Blues", domain = spdf@data$pop_2014)
pal2 <- colorNumeric(palette = "Reds", domain = spdf@data$pop_2013)

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
              label = ~stringr::str_c(
                name, " ",
                formatC(pop_2014, big.mark = ",", format = "d")),
              labelOptions = labelOptions(direction = "auto"),
              highlightOptions = highlightOptions(
                color = "#ff0000", opacity = 1, weight = 2, fillOpacity = 1,
                bringToFront = TRUE, sendToBack = TRUE),
              group = "2014") %>%
  addPolygons(data = spdf, weight = 1, color = "#000000",
              fillColor = ~pal2(pop_2013),
              fillOpacity = 0.7,
              label = ~stringr::str_c(
                name, " ",
                formatC(pop_2014, big.mark = ",", format = "d")),
              labelOptions = labelOptions(direction = "auto"),
              highlightOptions = highlightOptions(
                color = "#00ff00", opacity = 1, weight = 2, fillOpacity = 1,
                bringToFront = TRUE, sendToBack = TRUE),
              group = "2013") %>%
  addLayersControl(
    baseGroups = c("2014", "2013"),
    position = "topleft",
    options = layersControlOptions(collapsed = FALSE)
  )
