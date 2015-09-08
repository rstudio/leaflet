leafletSimpleGraticuleDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-simplegraticule",
      "0.1.0",
      system.file("htmlwidgets/plugins/Leaflet.SimpleGraticule", package = "leaflet"),
      script = c("L.SimpleGraticule.js", "SimpleGraticule-binding.js"),
      stylesheet = "L.SimpleGraticule.js"
    )
  )
}

#' Add a simple Graticule on the map
#'
#' @param map a map widget object
#' @param
#' interval,showOriginLabel,redraw
#' see \url{https://github.com/ablakey/Leaflet.SimpleGraticule}
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addSimpleGraticule()
#'
#' @export
addSimpleGraticule <- function(
  map,
  interval = 20,
  showOriginLabel = TRUE,
  redraw = 'move',
  layerId = NULL,
  group=NULL
) {
  map$dependencies <- c(map$dependencies, leafletSimpleGraticuleDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addSimpleGraticule'
    , interval
    , showOriginLabel
    , redraw
    , layerId
    , group
  )
}
