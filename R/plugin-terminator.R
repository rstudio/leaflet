leafletTerminatorDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-terminator",
      "0.1.0",
      system.file("htmlwidgets/plugins/Leaflet.Terminator", package = "leaflet"),
      script = c("L.Terminator.js", "Terminator-binding.js")
    )
  )
}

#' Add a daylight layer on top of the map
#'
#' @param map a map widget object
#' @param
#' resolution,time
#' see \url{https://github.com/joergdietrich/Leaflet.Terminator}
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addTerminator()
#'
#' @export
addTerminator <- function(
  map,
  resolution = 2,
  time = NULL,
  layerId = NULL,
  group=NULL
) {
  map$dependencies <- c(map$dependencies, leafletTerminatorDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addTerminator'
    , resolution
    , time
    , layerId
    , group
  )
}
