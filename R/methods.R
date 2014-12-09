#' @export
setView = function(map, center = NULL, zoom = NULL, options = list()) {
  if (!missing(center) && length(center) != 2)
    stop("'center' must be a numeric vector of the form c(lat, lng)")
  if (length(options) == 0) options = setNames(list(), character(0))
  map$x$setView = list(center, zoom, options)
  map
}

#' @export
fitMapBounds = function(map, lat1, lng1, lat2, lng2) {
  map$x$fitBounds = list(lat1, lng1, lat2, lng2)
  map
}
