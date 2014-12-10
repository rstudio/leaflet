#' Methods to manipulate the map widget
#'
#' A series of methods to manipulate the map.
#' @param map a map widget object created from \code{\link{leaflet}()}
#' @param center the coordinate of the map center as a numeric vector of the
#'   form \code{c(lat, lng)}
#' @param zoom the zoom level
#' @param options a list of zoom/pan options (see
#'   \url{http://leafletjs.com/reference.html#map-zoompanoptions})
#' @references \url{http://leafletjs.com/reference.html#map-set-methods}
#' @return The modified map widget.
#' @describeIn map-methods Sets the view of the map (center and zoom level)
#' @export
#' @examples library(leaflet)
#' m = leaflet() %>% addTiles() %>% setView(c(42.3489054,-71.0382679), zoom = 18)
#' m  # the RStudio 'headquarter'
#' m %>% fitBounds(40, -72, 43, -70)
#' m %>% clearBounds()  # world view
setView = function(map, center = NULL, zoom = NULL, options = list()) {
  if (!missing(center) && length(center) != 2)
    stop("'center' must be a numeric vector of the form c(lat, lng)")
  if (length(options) == 0) options = setNames(list(), character(0))
  map$x$setView = list(center, zoom, options)
  map
}

#' @describeIn map-methods Sets the bounds of a map
#' @param lat1,lng1,lat2,lng2 the coordinates of the map bounds
#' @export
fitBounds = function(map, lat1, lng1, lat2, lng2) {
  map$x$fitBounds = list(lat1, lng1, lat2, lng2)
  map
}

#' @describeIn map-methods Clear the bounds of a map, and the bounds will be
#'   automatically determined from latitudes and longitudes of the map elements
#'   if available (otherwise the full world view is used)
#' @export
clearBounds = function(map) {
  map$x$fitBounds = NULL
  map$x$setView = NULL
  map
}
