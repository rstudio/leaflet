leafletMagnifyingGlassDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-terminator",
      "0.1.0",
      system.file("htmlwidgets/plugins/Leaflet.MagnifyingGlass", package = "leaflet"),
      script = c('leaflet.magnifyingglass.js', 'Control.MagnifyingGlass.js', 'MagnifyingGlass-binding.js'),
      stylesheet = c('leaflet.magnifyingglass.css', 'Control.MagnifyingGlass.css')
    )
  )
}

#' Add a Magnifyer on a Map
#' See \url{https://raw.githubusercontent.com/bbecquet/Leaflet.MagnifyingGlass}
#'
#' @param map a map widget object
#' @param radius Integer, default 100. radius in pixels.
#' @param zoomOffset Integer 3, The zoom level offset between the main map zoom and the magnifying glass.
#' @param fixedZoom Integer -1, If different than -1,
#' defines a fixed zoom level to always use in the magnifying glass, ignoring the main map zoom and the zoomOffet value.
#' @param fixedPosition Boolean, default false,
#' If true, the magnifying glass will stay at the same position on the map, not following the mouse cursor.
#' @param latLng Default c(0,0)
#' The initial position of the magnifying glass, both on the main map and as the center of the magnified view.
#' If fixedPosition is true, it will always keep this position.
#' @param layers Currently not used
#' @param showControlButton whether to show a control button or not.
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addMagnifyingGlass()
#'
#' @export
addMagnifyingGlass <- function(
  map,
  radius = 100,
  zoomOffset = 3,
  fixedZoom = -1,
  fixedPosition = FALSE,
  latLng = c(0, 0),
  layers = NULL,
  showControlButton = FALSE,
  layerId = NULL,
  group=NULL
) {
  map$dependencies <- c(map$dependencies, leafletMagnifyingGlassDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addMagnifyingGlass'
    , radius
    , zoomOffset
    , fixedZoom
    , fixedPosition
    , latLng
    , layers
    , showControlButton
    , layerId
    , group
  )
}
