# Given a match.call() result, returns a named list of the arguments that were
# specified. (If the match.call is not from the immediate parent, then envir
# must be specified.) You can pass a vector of indices or names as `excludes`
# to prevent arguments from being represented in the list.
makeOpts <- function(matchCall, excludes = NULL, envir = parent.frame(2)) {
  args <- tail(as.list(matchCall), -1)
  options <- lapply(args, eval, envir = envir)
  options[excludes] <- NULL
  return(options)
}

#' @export
tileLayer = function(
  map,
  urlTemplate = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  minZoom = 0,
  maxZoom = 18,
  maxNativeZoom = NULL,
  tileSize = 256,
  subdomains = 'abc',
  errorTileUrl = '',
  attribution = '',
  tms = FALSE,
  continuousWorld = FALSE,
  noWrap = FALSE,
  zoomOffset = 0,
  zoomReverse = FALSE,
  opacity = 1.0,
  zIndex = NULL,
  unloadInvisibleTiles = NULL,
  updateWhenIdle = NULL,
  detectRetina = FALSE,
  reuseTiles = FALSE
  # bounds = TODO
) {
  options <- makeOpts(match.call(), c("map", "urlTemplate"))
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
mapPopup = function(
  map, lat, lng, content, layerId = NULL,
  maxWidth = 300,
  minWidth = 50,
  maxHeight = NULL,
  autoPan = TRUE,
  keepInView = FALSE,
  closeButton = TRUE,
  # offset = TODO,
  # autoPanPaddingTopLeft = TODO,
  # autoPanPaddingBottomRight = TODO,
  # autoPanPadding = TODO,
  zoomAnimation = TRUE,
  closeOnClick = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "content", "layerId"))
  map$x$popup = appendList(map$x$popup, list(
    lat, lng, content, layerId, options
  ))
  map
}

#' @export
mapMarker = function(
  map, lat, lng, layerId = NULL,
  icon = NULL,
  clickable = TRUE,
  draggable = FALSE,
  keyboard = TRUE,
  title = "",
  alt = "",
  zIndexOffset = 0,
  opacity = 1.0,
  riseOnHover = FALSE,
  riseOffset = 250
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "layerId"))
  map$x$marker = appendList(map$x$marker, list(
    lat, lng, layerId, options
  ))
  map
}

#' @export
mapCircleMarker = function(
  map, lat, lng, radius = 10, layerId = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "layerId"))
  map$x$circleMarker = appendList(map$x$circleMarker, list(
    lat, lng, radius, layerId, options
  ))
  map
}

#' @export
mapCircle = function(
  map, lat, lng, radius = 10, layerId = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "radius", "layerId"))
  map$x$circle = appendList(map$x$circle, list(
    lat, lng, radius, layerId, options
  ))
  map
}

#' @export
mapPolyline = function(
  map, lat, lng, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "layerId"))
  map$x$polyline = appendList(map$x$polyline,
    lat, lng, layerId, options
  )
  map
}

#' @export
mapRectangle = function(
  map, lat1, lng1, lat2, lng2, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat1", "lng1", "lat2", "lng2", "layerId"))
  map$x$rectangle = appendList(map$x$rectangle, list(
    lat1, lng1, lat2, lng2, layerId, options
  ))
  map
}

#' @export
mapPolygon = function(
  map, lat, lng, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  options <- makeOpts(match.call(), c("map", "lat", "lng", "layerId"))
  map$x$polygon = appendList(map$x$polygon, list(
    lat, lng, layerId, options
  ))
  map
}

#' @export
mapGeoJSON = function(map, data, layerId = NULL, options = list()) {
  map$x$geoJSON = appendList(map$x$geoJSON, list(
    data, layerId, options
  ))
  map
}
