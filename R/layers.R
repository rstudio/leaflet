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
  options = tileOptions()
) {
  options$attribution = attribution
  if (missing(urlTemplate) && is.null(options$attribution))
    options$attribution = paste(
      '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
      'contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    )
  appendMapData(map, getMapData(map), 'tileLayer', urlTemplate, options)
}

num2deg <- function(x, y, zoom) {
  n <- 2^zoom
  lng <- x / n * 360 - 180
  lat_rad <- (pi * (1 - 2 * y / n)) %>% sinh() %>% atan()
  lat_deg <- 180 * lat_rad / pi
  list(lat = lat_deg, lng = lng)
}

num2frac <- function(x, y, zoom) {
  n <- 2^zoom
  list(x = x / n, y = y / n)
}

scaleBy <- function(min, max, frac) {
  (frac * (max-min)) + min
}

extentForTileNum <- function(ext, x, y, zoom) {
  y <- 2^zoom - y - 1
  frac <- num2frac(x, y, zoom)
  xmin <- scaleBy(ext@xmin, ext@xmax, frac$x)
  ymin <- scaleBy(ext@ymin, ext@ymax, frac$y)

  frac2 <- num2frac(x+1, y+1, zoom)
  xmax <- scaleBy(ext@xmin, ext@xmax, frac2$x)
  ymax <- scaleBy(ext@ymin, ext@ymax, frac2$y)

  extent(xmin, xmax, ymin, ymax)
}

#' Raster layers (experimental)
#'
#' Add a raster object (from the \code{raster} package) as a tile
#' layer. The raster object must be in epsg:3857 (Spherical Mercator).
#' Note that this function currently ONLY works in Shiny contexts, as
#' it generates mapping tiles from the raster on-demand.
#'
#' @inheritParams setView
#' @param attribution the attribution text of the tile layer (HTML)
#' @param options a list of extra options; see \code{\link{tileOptions}}
#'
#' @export
addRaster = function(
  map,
  x,
  layerId = paste0("leafletRaster", sample.int(9999999, 1)),
  attribution = NULL,
  colorFunc = colorNumeric("RdBu", domain = c(minValue(x), maxValue(x))),
  options = tileOptions()
) {

  options$attribution = attribution

  # Verify that the projection is indeed epsg:3857. Ideally we would do the
  # reprojection on the fly, but projectRaster performance is currently too
  # slow.
  if (!grepl("\\+init=epsg:3857", projection(x))) {
    warning("Raster must be projected to epsg:3857 before calling addRaster")
  }

  if (!x@data@haveminmax) {
    x <- setMinMax(x)
  }

  # Fortunately Shiny lets us grab the active session without it being passed
  # explicitly to us.
  session <- shiny::getDefaultReactiveDomain()
  if (is.null(session)) {
    stop("leaflet::addRaster only works in a live Shiny session")
  }

  # We can use registerDataObj to add a new HTTP handler at a URL of Shiny's
  # choosing. In this case we expect requests for Slippy tiles, with URL
  # params z, x, and y; our job is to return image/png data.
  url <- session$registerDataObj(
    # The layer ID indicates the "slot" in the current Shiny session that our
    # data object will occupy. This can be any simple identifier and has not
    # much consequence except to garbage collect the previous value of layerId
    # each time a new one is registered.
    layerId,
    x, # The object itself
    function(data, req) {
      tile <- shiny::parseQueryString(req$QUERY_STRING) %>% lapply(as.numeric)
      cropTo <- extentForTileNum(extent(data), tile$x, tile$y, tile$z)
      tileImage <- raster::crop(data, cropTo)
      filename <- tempfile(fileext = ".png")
      on.exit(file.remove(filename), add = TRUE)

      #tileImage <- rasterfaster::resampleLayer(tileImage, raster(nrows=256, ncols=256))

      png(filename, width = 256, height = 256, units = "px")
      tryCatch(
        {
          par(mar = c(0,0,0,0), bg = "transparent", xaxs = "i", yaxs = "i")
          plot.new()
          plot.window(c(0,1), c(0,1))
          rawRaster <- as.raster(tileImage,
            col = colorFunc(
              # Rescale the colors to match the potentially reduced dynamic range
              # of this tile
              seq(from=minValue(tileImage), to=maxValue(tileImage), length.out=255)
            )
          )
          rasterImage(rawRaster, 0, 0, 1, 1, interpolate = FALSE)
        },
        finally = dev.off()
      )
      bytes <- readBin(filename, raw(), file.info(filename)$size)

      return(list(status = 200L,
        headers = list("Content-Type" = "image/png"),
        body = bytes))
    }
  )

  urlTemplate <- paste0(url, "&z={z}&x={x}&y={y}")

  appendMapData(map, getMapData(map), 'tileLayer', urlTemplate, options)
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
  appendMapData(map, data, 'popup', pts$lat, pts$lng, popup, layerId, options) %>%
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

#' @param icon the icon for markers; if you want to create a new icon using
#'   JavaScript, please remember to use \code{\link[htmlwidgets]{JS}()} on the
#'   JavaScript string; see \url{http://leafletjs.com/reference.html#icon}
#' @describeIn map-layers Add markders to the map
#' @export
addMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL,
  icon = NULL,
  popup = NULL,
  options = markerOptions(),
  data = getMapData(map)
) {
  options$icon = icon
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addMarkers")
  appendMapData(map, data, 'marker', pts$lat, pts$lng, layerId, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
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
  appendMapData(map, data, 'circleMarker', pts$lat, pts$lng, radius, layerId, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
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
  appendMapData(map, data, 'circle', pts$lat, pts$lng, radius, layerId, options, popup) %>%
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
  appendMapData(map, data, 'polyline', pgons, layerId, options, popup) %>%
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
  appendMapData(map, data, 'rectangle',lat1, lng1, lat2, lng2, layerId, options, popup) %>%
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
  appendMapData(map, data, 'polygon', pgons, layerId, options, popup) %>%
    expandLimitsBbox(pgons)
}

#' @param geojson a GeoJSON list
#' @describeIn map-layers Add GeoJSON layers to the map
#' @export
addGeoJSON = function(map, geojson, layerId = NULL) {
  appendMapData(map, getMapData(map), 'geoJSON', geojson, layerId)
}
