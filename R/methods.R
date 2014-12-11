#' Methods to manipulate the map widget
#'
#' A series of methods to manipulate the map.
#' @param map a map widget object created from \code{\link{leaflet}()}
#' @param lng The longitude of the map center
#' @param lat The latitude of the map center
#' @param zoom the zoom level
#' @param options a list of zoom/pan options (see
#'   \url{http://leafletjs.com/reference.html#map-zoompanoptions})
#' @references \url{http://leafletjs.com/reference.html#map-set-methods}
#' @return The modified map widget.
#' @describeIn map-methods Set the view of the map (center and zoom level)
#' @export
#' @examples library(leaflet)
#' m = leaflet() %>% addTiles() %>% setView(-71.0382679, 42.3489054, zoom = 18)
#' m  # the RStudio 'headquarter'
#' m %>% fitBounds(40, -72, 43, -70)
#' m %>% clearBounds()  # world view
setView = function(map, lng, lat, zoom, options = list()) {
  map$x$setView = list(c(lat, lng), zoom, options)
  map$x$fitBounds = NULL
  map
}

#' @describeIn map-methods Set the bounds of a map
#' @param lat1,lng1,lat2,lng2 the coordinates of the map bounds
#' @export
fitBounds = function(map, lat1, lng1, lat2, lng2) {
  map$x$fitBounds = list(lat1, lng1, lat2, lng2)
  map$x$setView = NULL
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
