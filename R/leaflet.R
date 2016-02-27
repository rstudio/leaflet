#' @importFrom grDevices col2rgb rgb
#' @importFrom methods substituteDirect
#' @importFrom stats na.omit quantile
#' @importFrom utils getFromNamespace packageVersion
NULL

#' Create a Leaflet map widget
#'
#' This function creates a Leaflet map widget using \pkg{htmlwidgets}. The
#' widget can be rendered on HTML pages generated from R Markdown, Shiny, or
#' other applications.
#'
#' The \code{data} argument is only needed if you are going to reference
#' variables in this object later in map layers. For example, \code{data} can be
#' a data frame containing columns \code{latitude} and \code{longtitude}, then
#' we may add a circle layer to the map by \code{leaflet(data) \%>\%
#' addCircles(lat = ~latitude, lng = ~longtitude)}, where the variables in the
#' formulae will be evaluated in the \code{data}.
#' @param data a data object (currently supported objects are matrices, data
#'   frames, and spatial objects from the \pkg{sp} package of classes
#'   \code{SpatialPoints}, \code{SpatialPointsDataFrame}, \code{Polygon},
#'   \code{Polygons}, \code{SpatialPolygons}, \code{SpatialPolygonsDataFrame},
#'   \code{Line}, \code{Lines}, \code{SpatialLines}, and
#'   \code{SpatialLinesDataFrame})
#' @param width the width of the map
#' @param height the height of the map
#' @param padding the padding of the map
#' @return A HTML widget object, on which we can add graphics layers using
#'   \code{\%>\%} (see examples).
#' @example inst/examples/leaflet.R
#' @export
leaflet = function(data = NULL, width = NULL, height = NULL, padding = 0) {
  htmlwidgets::createWidget(
    'leaflet',
    structure(
      list(),
      leafletData = data
    ),
    width = width, height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = '100%',
      defaultHeight = 400,
      padding = padding,
      browser.fill = TRUE
    )
  )
}

getMapData = function(map) {
  attr(map$x, "leafletData", exact = TRUE)
}

#' Set options on a leaflet map object
#'
#' @param map A map widget object created from \code{\link{leaflet}()}
#' @param zoomToLimits Controls whether the map is zooms to the limits of the
#'   elements on the map. This is useful for interactive applications where the
#'   map data is updated. If \code{"always"} (the default), the map always
#'   re-zooms when new data is received; if \code{"first"}, it zooms to the
#'   elements on the first rendering, but does not re-zoom for subsequent data;
#'   if \code{"never"}, it never re-zooms, not even for the first rendering.
#'
#' @examples
#' # Don't auto-zoom to the objects (can be useful in interactive applications)
#' leaflet() %>%
#'   addTiles() %>%
#'   addPopups(174.7690922, -36.8523071, 'R was born here!') %>%
#'   mapOptions(zoomToLimits = "first")
#' @export
mapOptions <- function(map, zoomToLimits = c("always", "first", "never")) {
  if (is.null(map$x$options))
    map$x$options <- list()

  zoomToLimits <- match.arg(zoomToLimits)
  map$x$options$zoomToLimits <- zoomToLimits

  map
}
