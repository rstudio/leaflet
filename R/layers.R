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

  if (length(lat) > 0) map$x$limits$lat = range(map$x$limits$lat, lat)
  if (length(lng) > 0) map$x$limits$lng = range(map$x$limits$lng, lng)

  map
}

# Same as expandLimits, but takes a polygon (that presumably has a bbox attr)
# rather than lat/lng.
expandLimitsBbox = function(map, poly) {
  bbox = attr(poly, "bbox", exact = TRUE)
  if (is.null(bbox)) stop("Polygon data had no bbox")
  expandLimits(map, bbox[2, ], bbox[1, ])
}

# Represents an initial bbox; if combined with any other bbox value using
# bboxAdd, the other bbox will be the result.
bboxNull = cbind(min = c(x = Inf, y = Inf), max = c(x = -Inf, y = -Inf))

# Combine two bboxes; the result will use the mins of the mins and the maxes of
# the maxes.
bboxAdd = function(a, b) {
  cbind(
    min = pmin(a[, 1], b[, 1]),
    max = pmax(a[, 2], b[, 2])
  )
}

#' Graphics elements and layers
#'
#' Add graphics elements and layers to the map widget.
#' @inheritParams setView
#' @param urlTemplate a character string as the URL template
#' @param attribution the attribution text of the tile layer (HTML)
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements
#' @return the new \code{map} object
#' @seealso \code{\link{tileOptions}}, \code{\link{popupOptions}},
#'   \code{\link{markerOptions}}, \code{\link{pathOptions}}
#' @references The Leaflet API documentation:
#'   \url{http://leafletjs.com/reference.html}
#' @describeIn map-layers Add a tile layer to the map
#' @export
addTiles = function(
  map,
  urlTemplate = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  attribution = NULL,
  layerId = NULL,
  options = tileOptions()
) {
  options$attribution = attribution
  if (missing(urlTemplate) && is.null(options$attribution))
    options$attribution = paste(
      '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
      'contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    )
  invokeMethod(map, getMapData(map), 'addTiles', urlTemplate, layerId, options)
}

#' Extra options for map elements and layers
#'
#' The rest of all possible options for map elements and layers that are not
#' listed in the layer functions.
#' @param
#' minZoom,maxZoom,maxNativeZoom,tileSize,subdomains,errorTileUrl,tms,continuousWorld,noWrap,zoomOffset,zoomReverse,zIndex,unloadInvisibleTiles,updateWhenIdle,detectRetina,reuseTiles
#' the tile layer options; see
#' \url{http://leafletjs.com/reference.html#tilelayer}
#' @describeIn map-options Options for tile layers
#' @export
tileOptions = function(
  minZoom = 0,
  maxZoom = 18,
  maxNativeZoom = NULL,
  tileSize = 256,
  subdomains = 'abc',
  errorTileUrl = '',
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
  list(
    minZoom = minZoom, maxZoom = maxZoom, maxNativeZoom = maxNativeZoom,
    tileSize = tileSize, subdomains = subdomains, errorTileUrl = errorTileUrl,
    tms = tms, continuousWorld = continuousWorld, noWrap = noWrap,
    zoomOffset = zoomOffset, zoomReverse = zoomReverse, opacity = opacity,
    zIndex = zIndex, unloadInvisibleTiles = unloadInvisibleTiles,
    updateWhenIdle = updateWhenIdle, detectRetina = detectRetina,
    reuseTiles = reuseTiles
  )
}

#' Remove elements from a map
#'
#' Remove one or more features from a map, identified by \code{layerId}; or,
#' clear all features of the given type.
#'
#' @note When used with a \code{\link{leaflet}}() map object, these functions
#' don't actually remove the features from the map object, but simply add an
#' operation that will cause those features to be removed after they are added.
#' In other words, if you add a polygon \code{"foo"} and the call
#' \code{removeShape("foo")}, it's not smart enough to prevent the polygon from
#' being added in the first place; instead, when the map is rendered, the
#' polygon will be added and then removed.
#'
#' For that reason, these functions aren't that useful with \code{leaflet} map
#' objects and are really intended to be used with \code{\link{leafletProxy}}
#' instead.
#'
#' @param map a map widget object, possibly created from \code{\link{leaflet}}()
#'   but more likely from \code{\link{leafletProxy}}()
#' @param layerId character vector; the layer id(s) of the item to remove
#' @return the new \code{map} object
#'
#' @name remove
#' @export
removeTiles = function(map, layerId) {
  invokeMethod(map, NULL, 'removeTiles', layerId)
}

#' @rdname remove
#' @export
clearTiles = function(map) {
  invokeMethod(map, NULL, 'clearTiles')
}

#' @param lng a numeric vector of longitudes, or a one-sided formula of the form
#'   \code{~x} where \code{x} is a variable in \code{data}; by default (if not
#'   explicitly provided), it will be automatically inferred from \code{data} by
#'   looking for a column named \code{lng}, \code{long}, or \code{longitude}
#'   (case-insensitively)
#' @param lat a vector of latitudes or a formula (similar to the \code{lng}
#'   argument; the names \code{lat} and \code{latitude} are used when guessing
#'   the latitude column from \code{data})
#' @param popup a character vector of the HTML content for the popups (you are
#'   recommended to escape the text using \code{\link[htmltools]{htmlEscape}()}
#'   for security reasons)
#' @param layerId the layer id
#' @param data the data object from which the argument values are derived; by
#'   default, it is the \code{data} object provided to \code{leaflet()}
#'   initially, but can be overridden
#' @describeIn map-layers Add popups to the map
#' @export
addPopups = function(
  map, lng = NULL, lat = NULL, popup, layerId = NULL,
  options = popupOptions(),
  data = getMapData(map)
) {
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addPopups")
  invokeMethod(map, data, 'addPopups', pts$lat, pts$lng, popup, layerId, options) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @param className a CSS class name set on an element
#' @param
#' maxWidth,minWidth,maxHeight,autoPan,keepInView,closeButton,zoomAnimation,closeOnClick
#' popup options; see \url{http://leafletjs.com/reference.html#popup}
#' @describeIn map-options Options for popups
#' @export
popupOptions = function(
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
  list(
    maxWidth = maxWidth, minWidth = minWidth, maxHeight = maxHeight,
    autoPan = autoPan, keepInView = keepInView, closeButton = closeButton,
    zoomAnimation = zoomAnimation, closeOnClick = closeOnClick, className = className
  )
}

#' @rdname remove
#' @export
removePopup = function(map, layerId) {
  invokeMethod(map, NULL, 'removePopup', layerId)
}

#' @rdname remove
#' @export
clearPopups = function(map) {
  invokeMethod(map, NULL, 'clearPopups')
}

#' @param icon the icon(s) for markers; an icon is represented by an R list of
#'   the form \code{list(iconUrl = '?', iconSize = c(x, y))}, and you can use
#'   \code{\link{iconList}()} to create a list of icons; note when you use an R
#'   list that contains images as local files, these local image files will be
#'   base64 encoded into the HTML page so the icon images will still be
#'   available even when you publish the map elsewhere (use \code{iconList(...,
#'   embed = FALSE)} if you do not want the images to be encoded and embedded)
#' @describeIn map-layers Add markders to the map
#' @export
addMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  icon = NULL,
  popup = NULL,
  options = markerOptions(),
  data = getMapData(map)
) {
  options$icon = L.icon(evalFormula(icon, data))
  options$iconGroup = attr(options$icon, 'iconGroup', exact = TRUE)
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addMarkers")
  invokeMethod(map, data, 'addMarkers', pts$lat, pts$lng, layerId, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
}

L.icon = function(options, embed = TRUE) {
  if (!is.list(options)) return(options)
  if (is.null(names(options))) {
    if (length(options) == 0) return()
    # in theory we need to check all sub-lists and all must be named
    if (is.null(names(options[[1]])))
      stop('The data for an individual icon must be a named list')
    # it is already a list of icons, so no further base64 encoding
    return(options)
  }
  for (i in c('iconUrl', 'iconRetinaUrl', 'shadowUrl', 'shadowRetinaUrl')) {
    Url = options[[i]]
    if (!embed || !is.character(Url) || !file.exists(Url)) next
    options[[i]] = knitr::image_uri(Url)
  }
  options
}

#' Create a list of icons
#'
#' An icon can be represented as a list of the form \code{list(iconUrl,
#' iconSize, ...)}. This function is vectorized over its arguments to create a
#' list of icons. See \url{http://leafletjs.com/reference.html#icon} for the
#' possible attributes of icons.
#'
#' Note some icon attributes are of length 2, such as \code{iconSize} and
#' \code{iconAnchor}, and \code{iconList()} provides two separate arguments for
#' these attributes, e.g. \code{iconSizeX = 20} and \code{iconSizeY = 40} means
#' \code{iconSize = c(20, 40)} internally. Shorter argument values will be
#' re-cycled. \code{NULL} values for these arguments will be ignored.
#' @param iconUrl the URL to the icon image
#' @param iconRetinaUrl the URL to a retina sized version of the icon image
#' @param iconSizeX,iconSizeY size of the icon image in pixels (\code{iconSizeX}
#'   is width and \code{iconSizeY} is height)
#' @param iconAnchorX,iconAnchorY the coordinates of the "tip" of the icon
#'   (relative to its top left corner, i.e. the top left corner means
#'   \code{iconAnchorX = 0} and \code{iconAnchorY = 0)}, and the icon will be
#'   aligned so that this point is at the marker's geographical location
#' @param shadowUrl the URL to the icon shadow image
#' @param shadowRetinaUrl the URL to the retina sized version of the icon shadow
#'   image
#' @param shadowSizeX,shadownSizeY size of the shadow image in pixels
#' @param shadowAnchorX,shadowAnchorY the coordinates of the "tip" of the shadow
#' @param popupAnchorX,popupAnchorY the coordinates of the point from which
#'   popups will "open", relative to the icon anchor
#' @param className a custom class name to assign to both icon and shadow images
#' @param embed whether to base64 encode local image files
#' @note The argument \code{embed = TRUE} can be useful when you render the map
#'   in a static HTML document and you want it to be self-contained (i.e. no
#'   external image dependencies). If you are sure that the icon images will
#'   always be available along with the HTML document, it is not necessary to
#'   encode them. When using the icons in Shiny, you may (pre-)render the icon
#'   images under the \file{www} directory of the app, and use them without
#'   base64 encoding them, e.g. you can use an icon \file{www/foo.png} by
#'   \code{iconList(iconUrl = 'foo.png', embed = FALSE)} (note there is no
#'   \samp{www} prefix in the icon URL).
#' @return A list of icon data that can be passed to the \code{icon} argument of
#'   \code{\link{addMarkers}()}.
#' @export
#' @example inst/examples/iconList.R
iconList = function(
  iconUrl = NULL, iconRetinaUrl = NULL, iconSizeX = NULL, iconSizeY = NULL,
  iconAnchorX = NULL, iconAnchorY = NULL, shadowUrl = NULL, shadowRetinaUrl = NULL,
  shadowSizeX = NULL, shadowSizeY = NULL, shadowAnchorX = NULL, shadowAnchorY = NULL,
  popupAnchorX = NULL, popupAnchorY = NULL, className = NULL, embed = TRUE
) {
  op = options(stringsAsFactors = FALSE); on.exit(options(op))
  attrs = filterNULL(list(
    iconUrl = iconUrl, iconRetinaUrl = iconRetinaUrl,
    iconSizeX = iconSizeX, iconSizeY = iconSizeY,
    iconAnchorX = iconAnchorX, iconAnchorY = iconAnchorY,
    shadowUrl = shadowUrl, shadowRetinaUrl = shadowRetinaUrl,
    shadowSizeX = shadowSizeX, shadowSizeY = shadowSizeY,
    shadowAnchorX = shadowAnchorX, shadowAnchorY = shadowAnchorY,
    popupAnchorX = popupAnchorX, popupAnchorY = popupAnchorY,
    className = className
  ))
  attrs = as.data.frame(do.call(cbind, attrs))
  group = apply(as.matrix(attrs), 1, paste, collapse = '\r') # one row to one value
  group = as.integer(factor(group, unique(group)))  # map rows to groups
  attrs = attrs[!duplicated(group), , drop = FALSE] # dedup
  structure(
    lapply(seq_len(nrow(attrs)), function(i) {
      L.icon(iconData(attrs[i, , drop = FALSE]), embed = embed)
    }),
    iconGroup = group
  )
}

# convert fooX and fooY variables to a list of foo = c(fooX, fooY)
iconData = function(options) {
  options = as.list(options)
  for (i in c('iconSize', 'iconAnchor', 'shadowSize', 'shadowAnchor', 'popupAnchor')) {
    x = paste0(i, 'X')
    y = paste0(i, 'Y')
    if (xor(is.null(options[[x]]), is.null(options[[y]]))) {
      stop('The icon options ', x, ' and ', y, ' must be both NULL or both not NULL')
    }
    if (!is.null(options[[x]])) {
      options[[i]] = as.numeric(c(options[[x]], options[[y]]))
      options[[x]] = options[[y]] = NULL
    }
  }
  options
}

#' @param clickable whether the element emits mouse events
#' @param
#'   draggable,keyboard,title,alt,zIndexOffset,opacity,riseOnHover,riseOffset
#'   marker options; see \url{http://leafletjs.com/reference.html#marker}
#' @describeIn map-options Options for markers
#' @export
markerOptions = function(
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
  list(
    clickable = clickable, draggable = draggable, keyboard = keyboard,
    title = title, alt = alt, zIndexOffset = zIndexOffset, opacity = opacity,
    riseOnHover = riseOnHover, riseOffset = riseOffset
  )
}

#' @param radius a numeric vector of radii for the circles; it can also be a
#'   one-sided formula, in which case the radius values are derived from the
#'   \code{data} (units in meters for circles, and pixels for circle markers)
#' @param stroke whether to draw stroke along the path (e.g. the borders of
#'   polygons or circles)
#' @param color stroke color
#' @param weight stroke width in pixels
#' @param opacity stroke opacity (or layer opacity for tile layers)
#' @param fill whether to fill the path with color (e.g. filling on polygons or
#'   circles)
#' @param fillColor fill color
#' @param fillOpacity fill opacity
#' @param dashArray a string that defines the stroke
#'   \href{https://developer.mozilla.org/en/SVG/Attribute/stroke-dasharray}{dash
#'   pattern}
#' @describeIn map-layers Add circle markers to the map
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
  popup = NULL,
  options = pathOptions(),
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray
  ))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircleMarkers")
  invokeMethod(map, data, 'addCircleMarkers', pts$lat, pts$lng, radius, layerId, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @rdname remove
#' @export
removeMarker = function(map, layerId) {
  invokeMethod(map, NULL, 'removeMarker', layerId)
}

#' @rdname remove
#' @export
clearMarkers = function(map) {
  invokeMethod(map, NULL, 'clearMarkers')
}

#' @param lineCap a string that defines
#'   \href{https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linecap}{shape
#'    to be used at the end} of the stroke
#' @param lineJoin a string that defines
#'   \href{https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linejoin}{shape
#'    to be used at the corners} of the stroke
#' @param pointerEvents sets the \code{pointer-events} attribute on the path if
#'   SVG backend is used
#' @describeIn map-options Options for vector layers (polylines, polygons,
#'   rectangles, and circles, etc)
#' @export
pathOptions = function(
  lineCap = NULL,
  lineJoin = NULL,
  clickable = TRUE,
  pointerEvents = NULL,
  className = ""
) {
  list(
    lineCap = lineCap, lineJoin = lineJoin, clickable = clickable,
    pointerEvents = pointerEvents, className = className
  )
}

#' @describeIn map-layers Add circles to the map
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
  popup = NULL,
  options = pathOptions(),
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray
  ))
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircles")
  invokeMethod(map, data, 'addCircles', pts$lat, pts$lng, radius, layerId, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @param smoothFactor how much to simplify the polyline on each zoom level
#'   (more means better performance and less accurate representation)
#' @param noClip whether to disable polyline clipping
#' @describeIn map-layers Add polylines to the map
#' @export
addPolylines = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = FALSE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  popup = NULL,
  options = pathOptions(),
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray, smoothFactor = smoothFactor, noClip = noClip
  ))
  pgons = derivePolygons(data, lng, lat, missing(lng), missing(lat), "addPolylines")
  invokeMethod(map, data, 'addPolylines', pgons, layerId, options, popup) %>%
    expandLimitsBbox(pgons)
}

#' @param lng1,lat1,lng2,lat2 latitudes and longitudes of the south-west and
#'   north-east corners of rectangles
#' @describeIn map-layers Add rectangles to the map
#' @export
addRectangles = function(
  map, lng1, lat1, lng2, lat2, layerId = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  popup = NULL,
  options = pathOptions(),
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray, smoothFactor = smoothFactor, noClip = noClip
  ))
  lng1 = resolveFormula(lng1, data)
  lat1 = resolveFormula(lat1, data)
  lng2 = resolveFormula(lng2, data)
  lat2 = resolveFormula(lat2, data)
  invokeMethod(map, data, 'addRectangles',lat1, lng1, lat2, lng2, layerId, options, popup) %>%
    expandLimits(c(lat1, lat2), c(lng1, lng2))
}

#' @describeIn map-layers Add polygons to the map
#' @export
addPolygons = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  popup = NULL,
  options = pathOptions(),
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray, smoothFactor = smoothFactor, noClip = noClip
  ))
  pgons = derivePolygons(data, lng, lat, missing(lng), missing(lat), "addPolygons")
  invokeMethod(map, data, 'addPolygons', pgons, layerId, options, popup) %>%
    expandLimitsBbox(pgons)
}

#' @rdname remove
#' @export
removeShape = function(map, layerId) {
  invokeMethod(map, NULL, 'removeShape', layerId)
}

#' @rdname remove
#' @export
clearShapes = function(map) {
  invokeMethod(map, NULL, 'clearShapes')
}

#' @param geojson a GeoJSON list
#' @describeIn map-layers Add GeoJSON layers to the map
#' @export
addGeoJSON = function(map, geojson, layerId = NULL) {
  invokeMethod(map, getMapData(map), 'addGeoJSON', geojson, layerId)
}

#' @rdname remove
#' @export
removeGeoJSON = function(map, layerId) {
  invokeMethod(map, NULL, 'removeGeoJSON', layerId)
}

#' @rdname remove
#' @export
clearGeoJSON = function(map) {
  invokeMethod(map, NULL, 'clearGeoJSON')
}
