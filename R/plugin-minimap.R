leafletMiniMapDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-minimap",
      "0.1.0",
      system.file("htmlwidgets/plugins/Leaflet-MiniMap", package = "leaflet"),
      script = c('Control.Minimap.min.js', 'Minimap-binding.js'),
      stylesheet = c('Control.Minimap.min.css')
    )
  )
}

#' Add a minimap to the Map
#'
#' @param map a map widget object
#' @param
#' position,width,height,collapsedWidth,collapsedHeight; see
#' \url{https://github.com/Norkart/Leaflet-MiniMap}
#' @param
#' zoomLevelOffset,zoomLevelFixed,zoomAnimation,toggleDisplay,autoToggleDisplay; see
#' \url{https://github.com/Norkart/Leaflet-MiniMap}
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addMiniMap()
#'
#' @export
addMiniMap <- function(
  map,
  position = 'bottomright',
  width = 150,
  height = 150,
  collapsedWidth = 19,
  collapsedHeight = 19,
  zoomLevelOffset = -5,
  zoomLevelFixed = NULL,
  zoomAnimation = FALSE,
  toggleDisplay = FALSE,
  autoToggleDisplay = NULL
) {
  map$dependencies <- c(map$dependencies, leafletMiniMapDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addMiniMap'
    , position
    , width
    , height
    , collapsedWidth
    , collapsedHeight
    , zoomLevelOffset
    , zoomLevelFixed
    , zoomAnimation
    , toggleDisplay
    , autoToggleDisplay
  )
}
