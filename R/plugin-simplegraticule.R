leafletSimpleGraticuleDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-simplegraticule",
      "0.1.0",
      system.file("htmlwidgets/plugins/Leaflet.SimpleGraticule", package = "leaflet"),
      script = c("L.SimpleGraticule.js", "SimpleGraticule-binding.js"),
      stylesheet = "L.SimpleGraticule.css"
    )
  )
}

#' Add a simple Graticule on the map
#' see \url{https://github.com/ablakey/Leaflet.SimpleGraticule}
#'
#' @param map a map widget object
#' @param interval The spacing in map units between horizontal and vertical lines.
#' @param showOriginLabel  true Whether or not to show '(0,0)' at the origin.
#' @param redraw on which map event to redraw the graticule. On move is default but moveend can be smoother.
#' @param hidden hide on start
#' @param zoomIntervals use different intervals in different zoom levels. If not specified, all zoom levels use value in interval option.

#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addSimpleGraticule()
#'
#' @export
addSimpleGraticule <- function(
  map,
  interval = 20,
  showOriginLabel = TRUE,
  redraw = 'move',
  hidden = FALSE,
  zoomIntervals = list(),
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
    , hidden
    , zoomIntervals
    , layerId
    , group
  )
}
