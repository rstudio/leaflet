#' @export
tileLayer = function(
  map,
  urlTemplate = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  options = list()
) {
  if (missing(urlTemplate) && is.null(options$attribution))
    options$attribution = paste(
      '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
      'contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    )
  map$x$tileLayer =  appendList(
    map$x$tileLayer, list(urlTemplate = urlTemplate, options = options)
  )
  map
}

#' @export
popup = function(
  map, lat, lng, content, layerId = NULL, options = list(), eachOptions = list()
) {
  map$x$popup = appendList(map$x$popup, list(
    lat, lng, content, layerId, options, eachOptions
  ))
  map
}

#' @export
marker = function(map, lat, lng, layerId = NULL, options = list(), eachOptions = list()) {
  map$x$marker = appendList(map$x$marker, list(
    lat, lng, layerId, options, eachOptions
  ))
  map
}

#' @export
circleMarker = function(
  map, lat, lng, radius = 10, layerId = NULL, options = list(), eachOptions = list()
) {
  map$x$circleMarker = appendList(map$x$circleMarker, list(
    lat, lng, radius, layerId, options, eachOptions
  ))
  map
}

#' @export
circle = function(
  map, lat, lng, radius = 10, layerId = NULL, options = list(), eachOptions = list()
) {
  map$x$circle = appendList(map$x$circle, list(
    lat, lng, radius, layerId, options, eachOptions
  ))
  map
}

#' @export
polyline = function(
  map, lat, lng, layerId = NULL, options = list(), eachOptions = list()
) {
  map$x$polyline = appendList(map$x$polyline, list(
    matrix(c(lat, lng), ncol = 2), layerId, options, eachOptions
  ))
  map
}

#' @export
rectangle = function(
  map, lat1, lng1, lat2, lng2, layerId = NULL, options = list(), eachOptions = list()
) {
  map$x$rectangle = appendList(map$x$rectangle, list(
    lat1, lng1, lat2, lng2, layerId, options, eachOptions
  ))
  map
}

#' @export
polygon = function(map, lat, lng, layerId = NULL, options = list(), eachOptions = list()) {
  map$x$polygon = appendList(map$x$polygon, list(
    lat, lng, layerId, options, eachOptions
  ))
  map
}

#' @export
geoJSON = function(map, data, layerId = NULL, options = list()) {
  map$x$geoJSON = appendList(map$x$geoJSON, list(
    data, layerId, options
  ))
  map
}
