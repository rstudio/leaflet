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
#' @param id a character string as the identifier of the map (you do not need to
#'   provide it unless you want to manipulate the map later in Shiny)
#' @param width the width of the map
#' @param height the height of the map
#' @param padding the padding of the map
#' @return A HTML widget object, on which we can add graphics layers using
#'   \code{\%>\%} (see examples).
#' @example inst/examples/leaflet.R
#' @export
leaflet = function(data = NULL, id = NULL, width = NULL, height = NULL, padding = 0) {
  htmlwidgets::createWidget(
    'leafletjs',
    structure(
      list(mapId = id),
      leafletData = data
    ),
    width = width, height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = 'auto',
      defaultHeight = 'auto',
      padding = padding,
      browser.fill = TRUE
    )
  )
}

getMapData = function(map) {
  attr(map$x, "leafletData", exact = TRUE)
}
