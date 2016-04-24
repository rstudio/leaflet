leafletGPSDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-gps",
      "0.1.0",
      system.file("htmlwidgets/plugins/leaflet-gps", package = "leaflet"),
      script = c('leaflet-gps.min.js', 'leaflet-gps-binding.js'),
      stylesheet = c('leaflet-gps.min.css')
    )
  )
}

#' Add a gps to the Map
#' \url{https://github.com/Norkart/Leaflet-MiniMap}
#'
#' @param map a map widget object
#' @export
addControlGPS <- function(
  map
) {
  map$dependencies <- c(map$dependencies, leafletGPSDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addControlGPS'
  )
}
