# Evaluate list members that are formulae, using the map data as the environment
# (if provided, otherwise the formula environment)
evalFormula = function(list, data) {
  evalAll = function(x) {
    if (is.list(x)) {
      structure(lapply(x, evalAll), class = class(x))
    } else resolveFormula(x, data)
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

#' @param group the name of the group whose members should be removed
#' @rdname remove
#' @export
clearGroup <- function(map, group) {
  invokeMethod(map, getMapData(map), 'clearGroup', group);
}

#' Show or hide layer groups
#'
#' Hide groups of layers without removing them from the map entirely. Groups are
#' created using the \code{group} parameter that is included on most layer
#' adding functions.
#'
#' @param map the map to modify
#' @param group character vector of one or more group names to show or hide
#'
#' @seealso \code{\link{addLayersControl}} to allow users to show/hide layer
#'   groups interactively
#'
#' @export
showGroup = function(map, group) {
  invokeMethod(map, getMapData(map), 'showGroup', group)
}

#' @rdname showGroup
#' @export
hideGroup = function(map, group) {
  invokeMethod(map, getMapData(map), 'hideGroup', group)
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
#' @seealso \code{\link{tileOptions}}, \code{\link{WMSTileOptions}},
#'   \code{\link{popupOptions}}, \code{\link{markerOptions}},
#'   \code{\link{pathOptions}}
#' @references The Leaflet API documentation:
#'   \url{http://leafletjs.com/reference.html}
#' @describeIn map-layers Add a tile layer to the map
#' @export
addTiles = function(
  map,
  urlTemplate = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  options = tileOptions()
) {
  options$attribution = attribution
  if (missing(urlTemplate) && is.null(options$attribution))
    options$attribution = paste(
      '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a>',
      'contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    )
  invokeMethod(map, getMapData(map), 'addTiles', urlTemplate, layerId, group,
    options)
}

epsg4326 <- "+proj=longlat +datum=WGS84 +no_defs"
epsg3857 <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"

#' Add a raster image as a layer
#'
#' Create an image overlay from a \code{RasterLayer} object. \emph{This is only
#' suitable for small to medium sized rasters}, as the entire image will be
#' embedded into the HTML page (or passed over the websocket in a Shiny
#' context).
#'
#' The \code{maxBytes} parameter serves to prevent you from accidentally
#' embedding an excessively large amount of data into your htmlwidget. This
#' value is compared to the size of the final compressed image (after the raster
#' has been projected, colored, and PNG encoded, but before base64 encoding is
#' applied). Set \code{maxBytes} to \code{Inf} to disable this check, but be
#' aware that very large rasters may not only make your map a large download but
#' also may cause the browser to become slow or unresponsive.
#'
#' By default, the \code{addRasterImage} function will project the RasterLayer
#' \code{x} to EPSG:3857 using the \code{raster} package's
#' \code{\link[raster]{projectRaster}} function. This can be a time-consuming
#' operation for even moderately sized rasters. Upgrading the \code{raster}
#' package to 2.4 or later will provide a large speedup versus previous
#' versions. If you are repeatedly adding a particular raster to your Leaflet
#' maps, you can perform the projection ahead of time using
#' \code{projectRasterForLeaflet()}, and call \code{addRasterImage} with
#' \code{project=FALSE}.
#'
#' @param map a map widget object
#' @param x a \code{RasterLayer} object--see \code{\link[raster]{raster}}
#' @param colors the color palette (see \code{\link{colorNumeric}}) or function
#'   to use to color the raster values (hint: if providing a function, set
#'   \code{na.color} to \code{"#00000000"} to make \code{NA} areas transparent)
#' @param opacity the base opacity of the raster, expressed from 0 to 1
#' @param attribution the HTML string to show as the attribution for this layer
#' @param layerId the layer id
#' @param group the name of the group this raster image should belong to (see
#'   the same parameter under \code{\link{addTiles}})
#' @param project if \code{TRUE}, automatically project \code{x} to the map
#'   projection expected by Leaflet (\code{EPSG:3857}); if \code{FALSE}, it's
#'   the caller's responsibility to ensure that \code{x} is already projected,
#'   and that \code{extent(x)} is expressed in WGS84 latitude/longitude
#'   coordinates
#' @param maxBytes the maximum number of bytes to allow for the projected image
#'   (before base64 encoding); defaults to 4MB.
#'
#' @examples
#' library(raster)
#'
#' r <- raster(xmn=-2.8, xmx=-2.79, ymn=54.04, ymx=54.05, nrows=30, ncols=30)
#' values(r) <- matrix(1:900, nrow(r), ncol(r), byrow = TRUE)
#' crs(r) <- CRS("+init=epsg:4326")
#'
#' leaflet() %>% addTiles() %>%
#'   addRasterImage(r, colors = "Spectral", opacity = 0.8)
#' @export
addRasterImage = function(
  map,
  x,
  colors = "Spectral",
  opacity = 1,
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  project = TRUE,
  maxBytes = 4*1024*1024
) {
  stopifnot(inherits(x, "RasterLayer"))

  if (project) {
    projected <- projectRasterForLeaflet(x)
  } else {
    projected <- x
  }
  bounds <- raster::extent(raster::projectExtent(raster::projectExtent(x, crs = sp::CRS(epsg3857)), crs = sp::CRS(epsg4326)))

  if (!is.function(colors)) {
    colors <- colorNumeric(colors, domain = NULL, na.color = "#00000000", alpha = TRUE)
  }

  tileData <- raster::values(projected) %>% colors() %>% col2rgb(alpha = TRUE) %>% as.raw()
  dim(tileData) <- c(4, ncol(projected), nrow(projected))
  pngData <- png::writePNG(tileData)
  if (length(pngData) > maxBytes) {
    stop("Raster image too large; ", length(pngData), " bytes is greater than maximum ", maxBytes, " bytes")
  }
  encoded <- base64enc::base64encode(pngData)
  uri <- paste0("data:image/png;base64,", encoded)

  latlng <- list(
    list(raster::ymax(bounds), raster::xmin(bounds)),
    list(raster::ymin(bounds), raster::xmax(bounds))
  )

  invokeMethod(map, getMapData(map), "addRasterImage", uri, latlng, opacity, attribution, layerId, group) %>%
    expandLimits(c(raster::ymin(bounds), raster::ymax(bounds)), c(raster::xmin(bounds), raster::xmax(bounds)))
}

#' @rdname addRasterImage
#' @export
projectRasterForLeaflet <- function(x) {
  raster::projectRaster(x, raster::projectExtent(x, crs = sp::CRS(epsg3857)))
}

#' @rdname remove
#' @export
removeImage = function(map, layerId) {
  invokeMethod(map, NULL, 'removeImage', layerId)
}

#' @rdname remove
#' @export
clearImages = function(map) {
  invokeMethod(map, NULL, 'clearImages')
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
#' clear all features of the given type or group.
#'
#' @note When used with a \code{\link{leaflet}}() map object, these functions
#'   don't actually remove the features from the map object, but simply add an
#'   operation that will cause those features to be removed after they are
#'   added. In other words, if you add a polygon \code{"foo"} and the call
#'   \code{removeShape("foo")}, it's not smart enough to prevent the polygon
#'   from being added in the first place; instead, when the map is rendered, the
#'   polygon will be added and then removed.
#'
#'   For that reason, these functions aren't that useful with \code{leaflet} map
#'   objects and are really intended to be used with \code{\link{leafletProxy}}
#'   instead.
#'
#'   WMS tile layers are extensions of tile layers, so they can also be removed
#'   or cleared via \code{removeTiles()} or \code{clearTiles()}.
#' @param map a map widget object, possibly created from \code{\link{leaflet}}()
#'   but more likely from \code{\link{leafletProxy}}()
#' @param layerId character vector; the layer id(s) of the item to remove
#' @return the new \code{map} object
#'
#' @name remove
#' @export
removeTiles = function(map, layerId) {
  invokeMethod(map, getMapData(map), 'removeTiles', layerId)
}

#' @rdname remove
#' @export
clearTiles = function(map) {
  invokeMethod(map, NULL, 'clearTiles')
}


#' @param baseUrl a base URL of the WMS service
#' @param layers comma-separated list of WMS layers to show
#' @describeIn map-layers Add a WMS tile layer to the map
#' @export
addWMSTiles = function(
  map, baseUrl, layerId = NULL, group = NULL,
  options = WMSTileOptions(), attribution = NULL, layers = ''
) {
  options$attribution = attribution
  options$layers = layers
  invokeMethod(map, getMapData(map), 'addWMSTiles', baseUrl, layerId, group, options)
}

#' @param styles comma-separated list of WMS styles
#' @param format WMS image format (use \code{'image/png'} for layers with
#'   transparency)
#' @param transparent if \code{TRUE}, the WMS service will return images with
#'   transparency
#' @param version version of the WMS service to use
#' @param crs Coordinate Reference System to use for the WMS requests, defaults
#'   to map CRS (don't change this if you're not sure what it means)
#' @param ... other tile options for \code{WMSTileOptions()} (all arguments of
#'   \code{tileOptions()} can be used)
#' @describeIn map-options Options for WMS tile layers
#' @export
WMSTileOptions = function(
  styles = '', format = 'image/jpeg', transparent = FALSE, version = '1.1.1',
  crs = NULL, ...
) {
  list(
    styles = styles, format = format, transparent = transparent,
    version = version, crs = crs, ...
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
#' @param group the name of the group the newly created layers should belong to
#'   (for \code{\link{clearGroup}} and \code{\link{addLayersControl}} purposes).
#'   Human-friendly group names are permitted--they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g. markers and polygons) can share the same group name.
#' @param data the data object from which the argument values are derived; by
#'   default, it is the \code{data} object provided to \code{leaflet()}
#'   initially, but can be overridden
#' @describeIn map-layers Add popups to the map
#' @export
addPopups = function(
  map, lng = NULL, lat = NULL, popup, layerId = NULL, group = NULL,
  options = popupOptions(),
  data = getMapData(map)
) {
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addPopups")
  invokeMethod(map, data, 'addPopups', pts$lat, pts$lng, popup, layerId, group, options) %>%
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
  invokeMethod(map, getMapData(map), 'removePopup', layerId)
}

#' @rdname remove
#' @export
clearPopups = function(map) {
  invokeMethod(map, NULL, 'clearPopups')
}

#' @param icon the icon(s) for markers; an icon is represented by an R list of
#'   the form \code{list(iconUrl = '?', iconSize = c(x, y))}, and you can use
#'   \code{\link{icons}()} to create multiple icons; note when you use an R list
#'   that contains images as local files, these local image files will be base64
#'   encoded into the HTML page so the icon images will still be available even
#'   when you publish the map elsewhere
#' @param clusterOptions if not \code{NULL}, markers will be clustered using
#'   \href{https://github.com/Leaflet/Leaflet.markercluster}{Leaflet.markercluster};
#'    you can use \code{\link{markerClusterOptions}()} to specify marker cluster
#'   options
#' @param clusterId the id for the marker cluster layer
#' @describeIn map-layers Add markders to the map
#' @export
addMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
  icon = NULL,
  popup = NULL,
  options = markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  if (!is.null(icon)) {
    # If custom icons are specified, we need to 1) deduplicate any URLs/files,
    # so we can efficiently send e.g. 1000 markers that all use the same 2
    # icons; and 2) do base64 encoding on any local icon files (as opposed to
    # URLs [absolute or relative] which will be left alone).

    # If formulas are present, they must be evaluated first so we can pack the
    # resulting values
    icon = evalFormula(list(icon), data)[[1]]

    if (inherits(icon, "leaflet_icon_set")) {
      icon = iconSetToIcons(icon)
    }

    # Pack and encode each URL vector; this will be reversed on the client
    icon$iconUrl         = b64EncodePackedIcons(packStrings(icon$iconUrl))
    icon$iconRetinaUrl   = b64EncodePackedIcons(packStrings(icon$iconRetinaUrl))
    icon$shadowUrl       = b64EncodePackedIcons(packStrings(icon$shadowUrl))
    icon$shadowRetinaUrl = b64EncodePackedIcons(packStrings(icon$shadowRetinaUrl))
    icon = filterNULL(icon)
  }

  if (!is.null(clusterOptions))
    map$dependencies = c(map$dependencies, markerClusterDependencies())

  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addMarkers")
  invokeMethod(
    map, data, 'addMarkers', pts$lat, pts$lng, icon, layerId, group, options, popup,
    clusterOptions, clusterId
  ) %>% expandLimits(pts$lat, pts$lng)
}

markerClusterDependencies = function() {
  list(
    htmltools::htmlDependency(
      'leaflet-markercluster',
      '0.4.0',
      system.file('htmlwidgets/plugins/Leaflet.markercluster', package = 'leaflet'),
      script = 'leaflet.markercluster.js',
      stylesheet = c('MarkerCluster.css', 'MarkerCluster.Default.css')
    )
  )
}

#' Make icon set
#'
#' @param ... icons created from \code{\link{makeIcon}()}
#' @export
#' @examples
#'
#' iconSet = iconList(
#'   red = makeIcon("leaf-red.png", iconWidth=32, iconHeight=32),
#'   green = makeIcon("leaf-green.png", iconWidth=32, iconHeight=32)
#' )
#'
#' iconSet[c('red', 'green', 'red')]
iconList = function(...) {
  res = structure(
    list(...),
    class = "leaflet_icon_set"
  )
  cls = unlist(lapply(res, inherits, 'leaflet_icon'))
  if (any(!cls))
    stop('Arguments passed to iconList() must be icon objects returned from makeIcon()')
  res
}

#' @export
`[.leaflet_icon_set` = function(x, i) {
  if (is.factor(i)) {
    i = as.character(i)
  }

  if (!is.character(i) && !is.numeric(i) && !is.integer(i)) {
    stop("Invalid subscript type '", typeof(i), "'")
  }

  structure(.subset(x, i), class = "leaflet_icon_set")
}

iconSetToIcons = function(x) {
  # c("iconUrl", "iconRetinaUrl", ...)
  cols = names(formals(makeIcon))
  # list(iconUrl = "iconUrl", iconRetinaUrl = "iconRetinaUrl", ...)
  cols = structure(as.list(cols), names = cols)

  # Construct an equivalent output to icons().
  filterNULL(lapply(cols, function(col) {
    # Pluck the `col` member off of each item in iconObjs and put them in an
    # unnamed list (or vector if possible).
    colVals = unname(sapply(x, `[[`, col))

    # If this is the common case where there's lots of values but they're all
    # actually the same exact thing, then just return one value; this will be
    # much cheaper to send to the client, and we'll do recycling on the client
    # side anyway.
    if (length(unique(colVals)) == 1) {
      return(colVals[[1]])
    } else {
      return(colVals)
    }
  }))
}

#' Define icon sets
#'
#' @inheritParams icons
#'
#' @export
makeIcon = function(iconUrl = NULL, iconRetinaUrl = NULL, iconWidth = NULL, iconHeight = NULL,
  iconAnchorX = NULL, iconAnchorY = NULL, shadowUrl = NULL, shadowRetinaUrl = NULL,
  shadowWidth = NULL, shadowHeight = NULL, shadowAnchorX = NULL, shadowAnchorY = NULL,
  popupAnchorX = NULL, popupAnchorY = NULL, className = NULL) {

  icon = filterNULL(list(
    iconUrl = iconUrl, iconRetinaUrl = iconRetinaUrl,
    iconWidth = iconWidth, iconHeight = iconHeight,
    iconAnchorX = iconAnchorX, iconAnchorY = iconAnchorY,
    shadowUrl = shadowUrl, shadowRetinaUrl = shadowRetinaUrl,
    shadowWidth = shadowWidth, shadowHeight = shadowHeight,
    shadowAnchorX = shadowAnchorX, shadowAnchorY = shadowAnchorY,
    popupAnchorX = popupAnchorX, popupAnchorY = popupAnchorY,
    className = className
  ))
  structure(icon, class = "leaflet_icon")
}

#' Create a list of icon data
#'
#' An icon can be represented as a list of the form \code{list(iconUrl,
#' iconSize, ...)}. This function is vectorized over its arguments to create a
#' list of icon data. Shorter argument values will be re-cycled. \code{NULL}
#' values for these arguments will be ignored.
#' @param iconUrl the URL or file path to the icon image
#' @param iconRetinaUrl the URL or file path to a retina sized version of the
#'   icon image
#' @param iconWidth,iconHeight size of the icon image in pixels
#' @param iconAnchorX,iconAnchorY the coordinates of the "tip" of the icon
#'   (relative to its top left corner, i.e. the top left corner means
#'   \code{iconAnchorX = 0} and \code{iconAnchorY = 0)}, and the icon will be
#'   aligned so that this point is at the marker's geographical location
#' @param shadowUrl the URL or file path to the icon shadow image
#' @param shadowRetinaUrl the URL or file path to the retina sized version of
#'   the icon shadow image
#' @param shadowWidth,shadowHeight size of the shadow image in pixels
#' @param shadowAnchorX,shadowAnchorY the coordinates of the "tip" of the shadow
#' @param popupAnchorX,popupAnchorY the coordinates of the point from which
#'   popups will "open", relative to the icon anchor
#' @param className a custom class name to assign to both icon and shadow images
#' @return A list of icon data that can be passed to the \code{icon} argument of
#'   \code{\link{addMarkers}()}.
#' @export
#' @example inst/examples/icons.R
icons = function(
  iconUrl = NULL, iconRetinaUrl = NULL, iconWidth = NULL, iconHeight = NULL,
  iconAnchorX = NULL, iconAnchorY = NULL, shadowUrl = NULL, shadowRetinaUrl = NULL,
  shadowWidth = NULL, shadowHeight = NULL, shadowAnchorX = NULL, shadowAnchorY = NULL,
  popupAnchorX = NULL, popupAnchorY = NULL, className = NULL
) {
  filterNULL(list(
    iconUrl = iconUrl, iconRetinaUrl = iconRetinaUrl,
    iconWidth = iconWidth, iconHeight = iconHeight,
    iconAnchorX = iconAnchorX, iconAnchorY = iconAnchorY,
    shadowUrl = shadowUrl, shadowRetinaUrl = shadowRetinaUrl,
    shadowWidth = shadowWidth, shadowHeight = shadowHeight,
    shadowAnchorX = shadowAnchorX, shadowAnchorY = shadowAnchorY,
    popupAnchorX = popupAnchorX, popupAnchorY = popupAnchorY,
    className = className
  ))
}

packStrings = function(strings) {
  if (length(strings) == 0) {
    return(NULL)
  }
  uniques = unique(strings)
  indices = match(strings, uniques)
  indices = indices - 1 # convert to 0-based for easy JS usage

  list(
    data = uniques,
    index = indices
  )
}

b64EncodePackedIcons = function(packedIcons) {
  if (is.null(packedIcons))
    return(packedIcons)

  # TODO: remove this when we've got our own encoding function
  markdown::markdownToHTML
  image_uri = getFromNamespace('.b64EncodeFile', 'markdown')
  packedIcons$data = sapply(packedIcons$data, function(icon) {
    if (is.character(icon) && file.exists(icon)) {
      image_uri(icon)
    } else {
      icon
    }
  }, USE.NAMES = FALSE)
  packedIcons
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

#' @param showCoverageOnHover when you mouse over a cluster it shows the bounds
#'   of its markers
#' @param zoomToBoundsOnClick when you click a cluster we zoom to its bounds
#' @param spiderfyOnMaxZoom when you click a cluster at the bottom zoom level we
#'   spiderfy it so you can see all of its markers
#' @param removeOutsideVisibleBounds clusters and markers too far from the
#'   viewport are removed from the map for performance
#' @describeIn map-options Options for marker clusters
#' @export
markerClusterOptions = function(
  showCoverageOnHover = TRUE, zoomToBoundsOnClick = TRUE,
  spiderfyOnMaxZoom = TRUE, removeOutsideVisibleBounds = TRUE, ...
) {
  list(
    showCoverageOnHover = showCoverageOnHover,
    zoomToBoundsOnClick = zoomToBoundsOnClick,
    spiderfyOnMaxZoom = spiderfyOnMaxZoom,
    removeOutsideVisibleBounds = removeOutsideVisibleBounds, ...
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
  map, lng = NULL, lat = NULL, radius = 10, layerId = NULL, group = NULL,
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
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray
  ))
  if (!is.null(clusterOptions))
    map$dependencies = c(map$dependencies, markerClusterDependencies())
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircleMarkers")
  invokeMethod(map, data, 'addCircleMarkers', pts$lat, pts$lng, radius,
      layerId, group, options, clusterOptions, clusterId, popup) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @rdname remove
#' @export
removeMarker = function(map, layerId) {
  invokeMethod(map, getMapData(map), 'removeMarker', layerId)
}

#' @rdname remove
#' @export
clearMarkers = function(map) {
  invokeMethod(map, NULL, 'clearMarkers')
}

#' @rdname remove
#' @export
removeMarkerCluster = function(map, layerId) {
  invokeMethod(map, getMapData(map), 'removeMarkerCluster', layerId)
}

#' @rdname remove
#' @export
clearMarkerClusters = function(map) {
  invokeMethod(map, NULL, 'clearMarkerClusters')
}

#' @param clusterId the id of the marker cluster layer
#' @rdname remove
#' @export
removeMarkerFromCluster = function(map, layerId, clusterId) {
  invokeMethod(map, getMapData(map), 'removeMarkerFromCluster', layerId, clusterId)
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
  map, lng = NULL, lat = NULL, radius = 10, layerId = NULL, group = NULL,
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
  invokeMethod(map, data, 'addCircles', pts$lat, pts$lng, radius, layerId, group, options, popup) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @param smoothFactor how much to simplify the polyline on each zoom level
#'   (more means better performance and less accurate representation)
#' @param noClip whether to disable polyline clipping
#' @describeIn map-layers Add polylines to the map
#' @export
addPolylines = function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
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
  invokeMethod(map, data, 'addPolylines', pgons, layerId, group, options, popup) %>%
    expandLimitsBbox(pgons)
}

#' @param lng1,lat1,lng2,lat2 latitudes and longitudes of the south-west and
#'   north-east corners of rectangles
#' @describeIn map-layers Add rectangles to the map
#' @export
addRectangles = function(
  map, lng1, lat1, lng2, lat2, layerId = NULL, group = NULL,
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
  invokeMethod(map, data, 'addRectangles',lat1, lng1, lat2, lng2, layerId, group, options, popup) %>%
    expandLimits(c(lat1, lat2), c(lng1, lng2))
}

#' @describeIn map-layers Add polygons to the map
#' @export
addPolygons = function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
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
  invokeMethod(map, data, 'addPolygons', pgons, layerId, group, options, popup) %>%
    expandLimitsBbox(pgons)
}

#' @rdname remove
#' @export
removeShape = function(map, layerId) {
  invokeMethod(map, getMapData(map), 'removeShape', layerId)
}

#' @rdname remove
#' @export
clearShapes = function(map) {
  invokeMethod(map, NULL, 'clearShapes')
}

#' @param geojson a GeoJSON list, or character vector of length 1
#' @describeIn map-layers Add GeoJSON layers to the map
#' @export
addGeoJSON = function(map, geojson, layerId = NULL, group = NULL,
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
  options = pathOptions()
) {
  options = c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray, smoothFactor = smoothFactor, noClip = noClip
  ))
  invokeMethod(map, getMapData(map), 'addGeoJSON', geojson, layerId, group, options)
}

#' @rdname remove
#' @export
removeGeoJSON = function(map, layerId) {
  invokeMethod(map, getMapData(map), 'removeGeoJSON', layerId)
}

#' @rdname remove
#' @export
clearGeoJSON = function(map) {
  invokeMethod(map, NULL, 'clearGeoJSON')
}

#' Add UI controls to switch layers on and off
#'
#' Uses Leaflet's built-in
#' \href{http://leafletjs.com/reference.html#control-layers}{layers control}
#' feature to allow users to choose one of several base layers, and to choose
#' any number of overlay layers to view.
#'
#' @param map the map to add the layers control to
#' @param baseGroups character vector where each element is the name of a group.
#'   The user will be able to choose one base group (only) at a time. This is
#'   most commonly used for mostly-opaque tile layers.
#' @param overlayGroups character vector where each element is the name of a
#'   group. The user can turn each overlay group on or off independently.
#' @param position position of control: 'topleft', 'topright', 'bottomleft', or
#'   'bottomright'
#' @param options a list of additional options, intended to be provided by
#'   a call to \code{layersControlOptions}
#'
#' @examples
#' \donttest{
#' leaflet() %>%
#'   addTiles(group = "OpenStreetMap") %>%
#'   addProviderTiles("Stamen.Toner", group = "Toner by Stamen") %>%
#'   addMarkers(runif(20, -75, -74), runif(20, 41, 42), group = "Markers") %>%
#'   addLayersControl(
#'     baseGroups = c("OpenStreetMap", "Toner by Stamen"),
#'     overlayGroups = c("Markers")
#'   )
#' }
#'
#' @export
addLayersControl = function(map,
  baseGroups = character(0), overlayGroups = character(0),
  position = c('topright', 'bottomright', 'bottomleft', 'topleft'),
  options = layersControlOptions()) {

  options = c(options, list(position = match.arg(position)))
  invokeMethod(map, getMapData(map), 'addLayersControl', baseGroups,
    overlayGroups, options)
}

#' @rdname addLayersControl
#' @param collapsed if \code{TRUE} (the default), the layers control will be
#'   rendered as an icon that expands when hovered over. Set to \code{FALSE}
#'   to have the layers control always appear in its expanded state.
#' @param autoZIndex if \code{TRUE}, the control will automatically maintain
#'   the z-order of its various groups as overlays are switched on and off.
#' @export
layersControlOptions = function(collapsed = TRUE, autoZIndex = TRUE) {
  list(collapsed = collapsed, autoZIndex = autoZIndex)
}

#' @rdname addLayersControl
#' @export
removeLayersControl = function(map) {
  invokeMethod(map, NULL, 'removeLayersControl')
}
