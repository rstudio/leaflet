library(magrittr)

fName <- "https://raw.githubusercontent.com/MinnPost/simple-map-d3/master/example-data/world-population.geo.json"

readGeoJson_ <- function(fName) {
  rmapshaper::ms_simplify(paste0(readLines(fName)))
}

readGeoJson <- memoise::memoise(readGeoJson_)
geoJson <- readGeoJson(fName)

spdf <- geojsonio::geojson_sp(geoJson)

#'
#'
#' Calculate population density only for countries with AREA & POP > 1.
spdf@data %<>% dplyr::mutate(
  AREA = as.numeric(as.character(AREA)),
  POP2005 = as.numeric(as.character(POP2005))
)

spdf <- subset(
  spdf,
  !(is.na(AREA) | AREA < 1 | is.na(POP2005) | POP2005 < 1)
)

spdf@data %<>%
  dplyr::mutate(
    POPDENSITY = POP2005 / AREA
  )
#'
#'
DT::datatable(spdf@data %>% dplyr::select(NAME, POP2005, AREA, POPDENSITY),
              options = list(pageLength = 5))
#'
#'

library(leaflet)
leaf <- leaflet(spdf)

#'
#'
#' ### Quantiles

qpal <- colorQuantile(rev(viridisLite::viridis(10)), spdf$POPDENSITY, n = 10)

leaf %>%
  addPolygons(weight = 1, color = "#333333", fillOpacity = 1,
              fillColor = ~qpal(POPDENSITY) ) %>%
  addLegend("bottomleft", pal = qpal, values = ~POPDENSITY,
            title = htmltools::HTML("Population Density<br/>(2005)"),
            opacity = 1 )


#'
#'
#' ### Bins
binpal <- colorBin(rev(viridisLite::viridis(10)), spdf$POPDENSITY, bins = 10)

leaf %>%
  addPolygons(weight = 1, color = "#333333", fillOpacity = 1,
              fillColor = ~binpal(POPDENSITY)) %>%
  addLegend("bottomleft", pal = binpal, values = ~POPDENSITY,
            title = htmltools::HTML("Population Density<br/>(2005)"),
            opacity = 1 )

#'
#'
#' ### Numeric
numpal <- colorNumeric(rev(viridisLite::viridis(256)), spdf$POPDENSITY)

leaf %>%
  addPolygons(weight = 1, color = "#333333", fillOpacity = 1,
              fillColor = ~numpal(POPDENSITY)) %>%
  addLegend("bottomleft", pal = numpal, values = ~POPDENSITY,
            title = htmltools::HTML("Population Density<br/>(2005)"),
            opacity = 1 )
#'
#'
