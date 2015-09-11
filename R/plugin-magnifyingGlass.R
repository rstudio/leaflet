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
#'
#' @param map a map widget object
#' @param
#' radius,zoomOffset,fixedZoom,fixedPosition,latLng,layers  see
#' \url{https://raw.githubusercontent.com/bbecquet/Leaflet.MagnifyingGlass}
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
