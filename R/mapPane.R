#' Add additional panes to leaflet map to control layer order
#'
#' @description
#' map panes can be created by supplying a name and a zIndex to control layer
#' ordering. We recommend a \code{zIndex} value between 400 (the default
#' overlay pane) and 500 (the default shadow pane). You can then use this pane
#' to render overlays (points, lines, polygons) by setting the \code{pane}
#' argument in \code{leafletOptions}. This will give you control
#' over the order of the layers, e.g. points always on top of polygons.
#' If two layers are provided to the same pane, overlay will be determined by
#' order of adding. See examples below.
#' See \url{http://www.leafletjs.com/reference-1.3.0.html#map-pane} for details.
#'
#' If the error "Cannot read property 'appendChild' of undefined" occurs, make
#' sure the pane being used for used for display has already been added to the map.
#'
#' @param map A \code{leaflet} or \code{mapview} object.
#' @param name The name of the new pane (refer to this in \code{leafletOptions}.
#' @param zIndex The zIndex of the pane. Panes with higher index are rendered
#' above panes with lower indices.
#'
#' @export
#' @examples
#' \donttest{rand_lng <- function(n = 10) rnorm(n, -93.65, .01)
#' rand_lat <- function(n = 10) rnorm(n, 42.0285, .01)
#'
#' random_data <- data.frame(
#'   lng = rand_lng(50),
#'   lat = rand_lat(50),
#'   radius = runif(50, 50, 150),
#'   circleId = paste0("circle #", 1:50),
#'   lineId = paste0("circle #", 1:50)
#' )
#'
#' # display circles (zIndex: 420) above the lines (zIndex: 410), even when added first
#' leaflet() %>%
#'   addTiles() %>%
#'   # move the center to Snedecor Hall
#'   setView(-93.65, 42.0285, zoom = 14) %>%
#'   addMapPane("ames_lines", zIndex = 410) %>% # shown below ames_circles
#'   addMapPane("ames_circles", zIndex = 420) %>% # shown above ames_lines
#'   # points above polygons
#'   addCircles(
#'     data = random_data, ~lng, ~lat, radius = ~radius, popup = ~circleId,
#'     options = pathOptions(pane = "ames_circles")
#'   ) %>%
#'   # lines in 'ames_lines' pane
#'   addPolylines(
#'     data = random_data, ~lng, ~lat, color = "#F00", weight = 20,
#'     options = pathOptions(pane = "ames_lines")
#'   )
#'
#'
#' # same example but circles (zIndex: 420) are below the lines (zIndex: 430)
#' leaflet() %>%
#'   addTiles() %>%
#'   # move the center to Snedecor Hall
#'   setView(-93.65, 42.0285, zoom = 14) %>%
#'   addMapPane("ames_lines", zIndex = 430) %>% # shown below ames_circles
#'   addMapPane("ames_circles", zIndex = 420) %>% # shown above ames_lines
#'   # points above polygons
#'   addCircles(
#'     data = random_data, ~lng, ~lat, radius = ~radius, popup = ~circleId,
#'     options = pathOptions(pane = "ames_circles")
#'   ) %>%
#'   # lines in 'ames_lines' pane
#'   addPolylines(
#'     data = random_data, ~lng, ~lat, color = "#F00", weight = 20,
#'     options = pathOptions(pane = "ames_lines")
#'   )
#'}
addMapPane = function(map, name, zIndex) {
  invokeMethod(map, getMapData(map), 'createMapPane', name, zIndex)
}
