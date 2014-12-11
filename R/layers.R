# Given a match.call() result, returns a named list of the arguments that were
# specified. (If the match.call is not from the immediate parent, then envir
# must be specified.) You can pass a vector of indices or names as `excludes`
# to prevent arguments from being represented in the list.
makeOpts = function(matchCall, excludes = NULL, envir = parent.frame(2)) {
  args = tail(as.list(matchCall), -1)
  args[excludes] = NULL
  options = lapply(args, eval, envir = envir)
  return(options)
}

# Evaluate list members that are formulae, using the map data as the environment
# (if provided, otherwise the formula environment)
evalFormula = function(list, data) {
  evalAll = function(x) {
    if (is.list(x)) lapply(x, evalAll) else resolveFormula(x, data)
  }
  evalAll(list)
}

# jcheng 12/10/2014: The limits/bbox handling was pretty rushed, unfortunately
# we have ended up with too many concepts. expandLimits just takes random
# lat/lng vectors, the sp package's Spatial objects can use `bbox()`, and our
# polygon lists (returned from polygonData()) use `attr(x, "bbox")` (though at
# least they are the same shape as the Spatial bounding boxes).

# Notifies the map of new latitude/longitude of items of interest on the map, so
# that we can expand the limits (i.e. bounding box). We will use this as the
# initial view if the user doesn't explicitly specify bounds using fitBounds.
expandLimits = function(map, lat, lng) {
  if (is.null(map$x$limits)) map$x$limits = list()

  # We remove NA's and check the lengths so we never call range() with an empty
  # set of arguments (or all NA's), which will cause a warning.

  lat = lat[is.finite(lat)]
  lng = lng[is.finite(lng)]

  if (length(lat) > 0)
    map$x$limits$lat = range(map$x$limits$lat, lat)
  if (length(lng) > 0)
    map$x$limits$lng = range(map$x$limits$lng, lng)

  map
}

# Same as expandLimits, but takes a polygon (that presumably has a bbox attr)
# rather than lat/lng.
expandLimitsBbox = function(map, poly) {
  bbox = attr(poly, "bbox", exact = TRUE)
  if (is.null(bbox))
    stop("Polygon data had no bbox")
  expandLimits(map, bbox[2,], bbox[1,])
}

# Represents an initial bbox; if combined with any other bbox value using
# bboxAdd, the other bbox will be the result.
bboxNull = cbind(min=c(x=Inf, y=Inf), max=c(x=-Inf, y=-Inf))

# Combine two bboxes; the result will use the mins of the mins and the maxes of
# the maxes.
bboxAdd = function(a, b) {
  cbind(
    min = pmin(a[,1], b[,1]),
    max = pmax(a[,2], b[,2])
  )
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
  options = makeOpts(match.call(), c("map", "urlTemplate"))
  if (missing(urlTemplate) && is.null(options$attribution))
    options$attribution = paste(
      '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
      'contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    )
  appendMapData(map, getMapData(map), 'tileLayer', urlTemplate, options)
}

#' @export
addPopups = function(
  map, lng = NULL, lat = NULL, content, layerId = NULL,
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
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "content", "layerId", "data"))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addPopups")
  appendMapData(map, data, 'popup', pts$lat, pts$lng, content, layerId, options) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @export
addMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  icon = NULL,
  clickable = TRUE,
  draggable = FALSE,
  keyboard = TRUE,
  title = "",
  alt = "",
  zIndexOffset = 0,
  opacity = 1.0,
  riseOnHover = FALSE,
  riseOffset = 250,
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "layerId", "data"))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addMarkers")
  appendMapData(map, data, 'marker', pts$lat, pts$lng, layerId, options) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @export
addCircleMarkers = function(
  map, lng = NULL, lat = NULL, radius = 10, layerId = NULL,
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
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "radius", "layerId", "data"))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircleMarkers")
  appendMapData(map, data, 'circleMarker', pts$lat, pts$lng, radius, layerId, options) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @export
addCircles = function(
  map, lng = NULL, lat = NULL, radius = 10, layerId = NULL,
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
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "radius", "layerId", "data"))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircles")
  appendMapData(map, data, 'circle', pts$lat, pts$lng, radius, layerId, options) %>%
    expandLimits(pts$lat, pts$lng)
}

# WARNING: lat and lng are LISTS of latitude and longitude vectors
#' @export
addPolylines = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  dashArray = NULL,
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "layerId", "data"))
  pgons = derivePolygons(data, lng, lat, missing(lng), missing(lat), "addPolylines")
  appendMapData(map, data, 'polyline', pgons, layerId, options) %>%
    expandLimitsBbox(pgons)
}

#' @export
addRectangles = function(
  map, lng1, lat1, lng2, lat2, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
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
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lat1", "lng1", "lat2", "lng2", "layerId", "data"))
  lng1 = resolveFormula(lng1, data)
  lat1 = resolveFormula(lat1, data)
  lng2 = resolveFormula(lng2, data)
  lat2 = resolveFormula(lat2, data)
  appendMapData(map, data, 'rectangle',lat1, lng1, lat2, lng2, layerId, options) %>%
    expandLimits(c(lat1, lat2), c(lng1, lng2))
}

# WARNING: lat and lng are LISTS of latitude and longitude vectors
#' @export
addPolygons = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
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
  className = "",
  data = getMapData(map)
) {
  options = makeOpts(match.call(), c("map", "lng", "lat", "layerId", "data"))
  pgons = derivePolygons(data, lng, lat, missing(lng), missing(lat), "addPolygons")
  appendMapData(map, data, 'polygon', pgons, layerId, options) %>%
    expandLimitsBbox(pgons)
}

#' @export
addGeoJSON = function(map, geojson, layerId = NULL) {
  appendMapData(map, getMapData(map), 'geoJSON', geojson, layerId)
}
