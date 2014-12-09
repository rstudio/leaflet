# Given a match.call() result, returns a named list of the arguments that were
# specified. (If the match.call is not from the immediate parent, then envir
# must be specified.) You can pass a vector of indices or names as `excludes`
# to prevent arguments from being represented in the list.
makeOpts <- function(matchCall, excludes = NULL, envir = parent.frame(2)) {
  args <- tail(as.list(matchCall), -1)
  args[excludes] <- NULL
  options <- lapply(args, eval, envir = envir)
  return(options)
}

# Evaluate list members that are formulae, using the map data as the environment
# (if provided, otherwise the formula environment)
evalFormula <- function(list, map) {
  data <- map$x$data
  evalAll <- function(list) {
    lapply(list, function(x) {
      if (is.list(x)) return(lapply(x, evalAll))
      if (inherits(x, 'formula')) x <- eval(x[[2]], data, environment(x))
      x
    })
  }
  evalAll(list)
}

#' @export
addTiles = function(
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
  appendMapData(map, 'tileLayer', urlTemplate = urlTemplate, options = options)
}

#' @export
addPopups = function(
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
  appendMapData(map, 'popup', lat, lng, content, layerId, options)
}

#' @export
addMarkers = function(
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
  appendMapData(map, 'marker', lat, lng, layerId, options)
}

#' @export
addCircleMarkers = function(
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
  appendMapData(map, 'circleMarker', lat, lng, radius, layerId, options)
}

#' @export
addCircles = function(
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
  appendMapData(map, 'circle', lat, lng, radius, layerId, options)
}

#' @export
addPolylines = function(
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
  appendMapData(map, 'polyline', lat, lng, layerId, options)
}

#' @export
addRectangles = function(
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
  appendMapData(map, 'rectangle',lat1, lng1, lat2, lng2, layerId, options)
}

#' @export
addPolygons = function(
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
  appendMapData(map, 'polygon', lat, lng, layerId, options)
}

#' @export
addGeoJSON = function(map, data, layerId = NULL, options = list()) {
  appendMapData(map, 'geoJSON', data, layerId, options)
}
