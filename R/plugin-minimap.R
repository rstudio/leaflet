utils::globalVariables(c("providers")) # To make R CMD Check happy

leafletMiniMapDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-minimap",
      "3.3.1",
      "htmlwidgets/plugins/Leaflet-MiniMap",
      package = "leaflet",
      script = c("Control.MiniMap.min.js", "Minimap-binding.js"),
      stylesheet = c("Control.MiniMap.min.css")
    )
  )
}

#' Add a minimap to the Map
#' \url{https://github.com/Norkart/Leaflet-MiniMap}
#'
#' @param map a map widget object
#' @param position The standard Leaflet.Control position parameter,
#'    used like all the other controls.
#' Defaults to "bottomright".
#' @param width  The width of the minimap in pixels. Defaults to 150.
#' @param height The height of the minimap in pixels. Defaults to 150.
#' @param collapsedWidth The width of the toggle marker and the minimap
#'    when collapsed, in pixels. Defaults to 19.
#' @param collapsedHeight The height of the toggle marker and the minimap
#'    when collapsed, in pixels. Defaults to 19.
#' @param zoomLevelOffset The offset applied to the zoom in the minimap compared
#'    to the zoom of the main map. Can be positive or negative, defaults to -5.
#' @param zoomLevelFixed  Overrides the offset to apply a fixed zoom level to
#'    the minimap regardless of the main map zoom.
#'    Set it to any valid zoom level, if unset zoomLevelOffset is used instead.
#' @param centerFixed Applies a fixed position to the minimap regardless of
#'    the main map's view / position. Prevents panning the minimap, but does
#'    allow zooming (both in the minimap and the main map).
#'    If the minimap is zoomed, it will always zoom around the centerFixed point.
#'    You can pass in a LatLng-equivalent object. Defaults to false.
#' @param zoomAnimation Sets whether the minimap should have an animated zoom.
#'    (Will cause it to lag a bit after the movement of the main map.)
#'    Defaults to false.
#' @param toggleDisplay Sets whether the minimap should have a button to minimise it.
#'    Defaults to false.
#' @param autoToggleDisplay Sets whether the minimap should hide automatically,
#'    if the parent map bounds does not fit within the minimap bounds.
#'    Especially useful when 'zoomLevelFixed' is set.
#' @param minimized Sets whether the minimap should start in a minimized position.
#' @param aimingRectOptions Sets the style of the aiming rectangle by passing in
#'    a Path.Options (\url{https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#path-options}) object.
#'    (Clickable will always be overridden and set to false.)
#' @param shadowRectOptions Sets the style of the aiming shadow rectangle by passing in
#'    a Path.Options (\url{https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#path-option}) object.
#'    (Clickable will always be overridden and set to false.)
#' @param strings Overrides the default strings allowing for translation.
#' @param tiles URL for tiles or one of the pre-defined providers.
#' @param mapOptions Sets Leaflet options for the MiniMap map.
#'    It does not override the MiniMap default map options but extends them.
#' @examples
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addMiniMap()
#' leaf
#'
#' @seealso \code{\link{providers}}
#' @export
addMiniMap <- function(
  map,
  position = "bottomright",
  width = 150,
  height = 150,
  collapsedWidth = 19,
  collapsedHeight = 19,
  zoomLevelOffset = -5,
  zoomLevelFixed = FALSE,
  centerFixed = FALSE,
  zoomAnimation = FALSE,
  toggleDisplay = FALSE,
  autoToggleDisplay = FALSE,
  minimized = FALSE,
  aimingRectOptions = list(color = "#ff7800", weight = 1, clickable = FALSE),
  shadowRectOptions = list(color = "#000000", weight = 1, clickable = FALSE,
                           opacity = 0, fillOpacity = 0),
  strings = list(hideText = "Hide MiniMap", showText = "Show MiniMap"),
  tiles = NULL,
  mapOptions = list()
) {

  # determin tiles to use
  tilesURL <- NULL
  tilesProvider <- NULL
 if (!is.null(tiles)) {
   if (tiles %in% providers) {
      map$dependencies <- c(map$dependencies, leafletProviderDependencies())
      tilesProvider <- tiles
    } else {
      tilesURL <- tiles
    }
  }

  map$dependencies <- c(map$dependencies, leafletMiniMapDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , "addMiniMap"
    , tilesURL
    , tilesProvider
    , position
    , width
    , height
    , collapsedWidth
    , collapsedHeight
    , zoomLevelOffset
    , zoomLevelFixed
    , centerFixed
    , zoomAnimation
    , toggleDisplay
    , autoToggleDisplay
    , minimized
    , aimingRectOptions
    , shadowRectOptions
    , strings
    , mapOptions
  )
}
