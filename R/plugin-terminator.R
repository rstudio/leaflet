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
#' See \url{https://github.com/joergdietrich/Leaflet.Terminator}
#'
#' @param map a map widget object
#' @param resolution the step size at which the terminator points are computed.
#'   The step size is 1 degree/resolution, i.e. higher resolution values have
#'   smaller step sizes and more points in the polygon. The default value is 2.
#' @param time Time
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @param options the path options for the daynight layer
#' @examples
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addTerminator()
#' leaf
#'
#' @export
addTerminator <- function(
  map,
  resolution = 2,
  time = NULL,
  layerId = NULL,
  group = NULL,
  options = pathOptions(pointerEvents = "none", clickable = FALSE) # Default unclickable
) {
  map$dependencies <- c(map$dependencies, leafletTerminatorDependencies())
  invokeMethod(
    map,
    getMapData(map),
    "addTerminator",
    resolution,
    time,
    layerId,
    group,
    options
  )
}
