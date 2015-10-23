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
#' \url{https://github.com/Norkart/Leaflet-MiniMap}
#'
#' @param map a map widget object
#' @param position The standard Leaflet.Control position parameter, used like all the other controls.
#' Defaults to 'bottomright'.
#' @param width  The width of the minimap in pixels. Defaults to 150.
#' @param height The height of the minimap in pixels. Defaults to 150.
#' @param collapsedWidth The width of the toggle marker and the minimap when collapsed, in pixels.
#' Defaults to 19.
#' @param collapsedHeight The height of the toggle marker and the minimap when collapsed, in pixels.
#' Defaults to 19.
#' @param zoomLevelOffset The offset applied to the zoom in the minimap compared to the zoom of the main map.
#' Can be positive or negative, defaults to -5.
#' @param zoomLevelFixed  Overrides the offset to apply a fixed zoom level to the minimap regardless of the main map zoom.
#' Set it to any valid zoom level, if unset zoomLevelOffset is used instead.
#' @param zoomAnimation Sets whether the minimap should have an animated zoom.
#' (Will cause it to lag a bit after the movement of the main map.) Defaults to false.
#' @param toggleDisplay Sets whether the minimap should have a button to minimise it.
#' Defaults to false.
#' @param autoToggleDisplay Sets whether the minimap should hide automatically,
#' if the parent map bounds does not fit within the minimap bounds.
#' Especially useful when 'zoomLevelFixed' is set.
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
