#' Evaluate list members that are formulae, using the map data as the environment
#'
#' Evaluates if provided. Otherwise, the formula environment is evaluated.
#' @param list with members as formulae
#' @param data map data
#' @keywords internal
#' @export
evalFormula <- function(list, data) {
  evalAll <- function(x) {
    if (is.list(x)) {
      # Use `x[] <-` so attributes on x are preserved
      x[] <- lapply(x, evalAll)
      x
    } else {
      resolveFormula(x, data)
    }
  }
  evalAll(list)
}

# jcheng 12/10/2014: The limits/bbox handling was pretty rushed, unfortunately
# we have ended up with too many concepts. expandLimits just takes random
# lat/lng vectors, the sp package's Spatial objects can use `bbox()`, and our
# polygon lists (returned from polygonData()) use `attr(x, "bbox")` (though at
# least they are the same shape as the Spatial bounding boxes).

#' Notifies the map of new latitude/longitude of items of interest on the map
# So that we can expand the limits (i.e., bounding box). We will use this as the
# initial view if the user doesn't explicitly specify bounds using fitBounds.
#' @param map map object
#' @param lat vector of latitudes
#' @param lng vector of longitudes
#' @export
expandLimits <- function(map, lat, lng) {
  if (is.null(map$x$limits)) {
    map$x$limits <- list()
  }

  # We remove NA's and check the lengths so we never call range() with an empty
  # set of arguments (or all NA's), which will cause a warning.

  lat <- lat[is.finite(lat)]
  lng <- lng[is.finite(lng)]

  if (length(lat) > 0) {
    map$x$limits$lat <- range(map$x$limits$lat, lat)
  }
  if (length(lng) > 0) {
    map$x$limits$lng <- range(map$x$limits$lng, lng)
  }

  map
}

#' Notifies the map of polygons of interest on the map
#'
#' Same as `expandLimits()`, but takes a polygon (that presumably has a bbox attr)
#' rather than lat/lng.
#' @param map map object
#' @param poly A spatial object representing a polygon.
#' @export
expandLimitsBbox <- function(map, poly) {
  bbox <- attr(poly, "bbox", exact = TRUE)
  if (is.null(bbox)) {
    stop("Polygon data had no bbox")
  }
  expandLimits(map, bbox[2, ], bbox[1, ])
}

# Represents an initial bbox; if combined with any other bbox value using
# bboxAdd, the other bbox will be the result.
bboxNull <- cbind(min = c(x = Inf, y = Inf), max = c(x = -Inf, y = -Inf))

# Combine two bboxes; the result will use the mins of the mins and the maxes of
# the maxes.
bboxAdd <- function(a, b) {
  cbind(
    min = pmin(a[, 1], b[, 1]),
    max = pmax(a[, 2], b[, 2])
  )
}

#' @param group the name of the group whose members should be removed
#' @rdname remove
#' @export
clearGroup <- function(map, group) {
  invokeMethod(map, getMapData(map), "clearGroup", group)
}

#' Show or hide layer groups
#'
#' Hide groups of layers without removing them from the map entirely. Groups are
#' created using the `group` parameter that is included on most layer
#' adding functions.
#'
#' @param map the map to modify
#' @param group character vector of one or more group names to show or hide
#'
#' @seealso [addLayersControl()] to allow users to show/hide layer
#'   groups interactively
#'
#' @export
showGroup <- function(map, group) {
  invokeMethod(map, getMapData(map), "showGroup", group)
}

#' @rdname showGroup
#' @export
hideGroup <- function(map, group) {
  invokeMethod(map, getMapData(map), "hideGroup", group)
}

#' Set options on layer groups
#'
#' Change options on layer groups. Currently the only option is to control what
#' zoom levels a layer group will be displayed at. The `zoomLevels` option
#' is not compatible with [layers control][addLayersControl()]; do not both
#' assign a group to zoom levels and use it with `addLayersControl()`.
#'
#' @param map the map to modify
#' @param group character vector of one or more group names to set options on
#' @param zoomLevels numeric vector of zoom levels at which group(s) should be
#'   visible, or `TRUE` to display at all zoom levels
#'
#' @examples
#' pal <- colorQuantile("YlOrRd", quakes$mag)
#'
#' leaflet() %>%
#'   # Basic markers
#'   addTiles(group = "basic") %>%
#'   addMarkers(data = quakes, group = "basic") %>%
#'   # When zoomed in, we'll show circles at the base of each marker whose
#'   # radius and color reflect the magnitude
#'   addProviderTiles(providers$Esri.WorldTopoMap, group = "detail") %>%
#'   addCircleMarkers(data = quakes, group = "detail", fillOpacity = 0.5,
#'     radius = ~mag * 5, color = ~pal(mag), stroke = FALSE) %>%
#'   # Set the detail group to only appear when zoomed in
#'   groupOptions("detail", zoomLevels = 7:18)
#'
#' @export
groupOptions <- function(map, group, zoomLevels = NULL) {
  if (is.null(zoomLevels)) {
    # Default to TRUE if nothing specified.
    zoomLevels <- TRUE
  }
  invokeMethod(
    map,
    getMapData(map),
    "setGroupOptions",
    group,
    list(zoomLevels = zoomLevels)
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
#' @return the new `map` object
#' @seealso [tileOptions()], [WMSTileOptions()],
#'   [popupOptions()], [markerOptions()],
#'   [pathOptions()]
#' @references The Leaflet API documentation:
#'   <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html>
#' @describeIn map-layers Add a tile layer to the map
#' @export
addTiles <- function(
  map,
  urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  options = tileOptions(),
  data = getMapData(map)
) {
  options$attribution <- attribution
  if (missing(urlTemplate) && is.null(options$attribution)) {
    options$attribution <- paste(
      "&copy; <a href=\"https://openstreetmap.org/copyright/\">OpenStreetMap</a>, ",
      "<a href=\"https://opendatacommons.org/licenses/odbl/\">ODbL</a>"
    )
  }
  invokeMethod(map, data, "addTiles", urlTemplate, layerId, group, options)
}

epsg4326 <- "+proj=longlat +datum=WGS84 +no_defs"
epsg3857 <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs" # nolint


#' Add a raster image as a layer
#'
#' Create an image overlay from a `RasterLayer` or a `SpatRaster`
#' object. *This is only suitable for small to medium sized rasters*,
#' as the entire image will be embedded into the HTML page (or passed over
#' the websocket in a Shiny context).
#'
#' The `maxBytes` parameter serves to prevent you from accidentally
#' embedding an excessively large amount of data into your htmlwidget. This
#' value is compared to the size of the final compressed image (after the raster
#' has been projected, colored, and PNG encoded, but before base64 encoding is
#' applied). Set `maxBytes` to `Inf` to disable this check, but be
#' aware that very large rasters may not only make your map a large download but
#' also may cause the browser to become slow or unresponsive.
#'
#' To reduce the size of a SpatRaster, you can use [terra::spatSample()]
#' as in `x = spatSample(x, 100000, method="regular", as.raster=TRUE)`. With
#' a `RasterLayer` you can use [raster::sampleRegular()] as in
#' `sampleRegular(x, 100000, asRaster=TRUE)`.
#'
#' By default, `addRasterImage()` will project the raster data
#' `x` to the Pseudo-Mercator projection (EPSG:3857). This can be a
#' time-consuming operation for even moderately sized rasters; although it is much
#' faster for SpatRasters than for RasterLayers.
#' If you are repeatedly adding a particular raster to your Leaflet
#' maps, you can perform the projection ahead of time using
#' `projectRasterForLeaflet()`, and call `addRasterImage()` with
#' `project = FALSE`.
#'
#' @param map a map widget object
#' @param x a [terra::SpatRaster()] or a `RasterLayer` object--see [raster::raster()]
#' @param colors the color palette (see [colorNumeric()]) or function
#'   to use to color the raster values (hint: if providing a function, set
#'   `na.color` to `"#00000000"` to make `NA` areas transparent).
#'   The palette is ignored if `x` is a SpatRaster with a color table or if
#'   it has RGB channels.
#' @param opacity the base opacity of the raster, expressed from 0 to 1
#' @param attribution the HTML string to show as the attribution for this layer
#' @param layerId the layer id
#' @param group the name of the group this raster image should belong to (see
#'   the same parameter under [addTiles()])
#' @param project if `TRUE`, automatically project `x` to the map
#'   projection expected by Leaflet (`EPSG:3857`); if `FALSE`, it's
#'   the caller's responsibility to ensure that `x` is already projected,
#'   and that `extent(x)` is expressed in WGS84 latitude/longitude
#'   coordinates
#' @param method the method used for computing values of the new, projected raster image.
#'   `"bilinear"` (the default) is appropriate for continuous data,
#'   `"ngb"` - nearest neighbor - is appropriate for categorical data.
#'   Ignored if `project = FALSE`. See [terra::project()] for details.
#' @param maxBytes the maximum number of bytes to allow for the projected image
#'   (before base64 encoding); defaults to 4MB.
#' @param options a list of additional options, intended to be provided by
#'   a call to [gridOptions()]
#' @template data-getMapData
#'
#' @seealso [addRasterLegend()] for an easy way to add a legend for a
#'   SpatRaster with a color table.
#'
#' @examplesIf rlang::is_installed("terra")
#' \donttest{
#'
#' r <- terra::rast(xmin = -2.8, xmax = -2.79, ymin = 54.04, ymax = 54.05, nrows = 30, ncols = 30)
#' terra::values(r) <- matrix(1:900, nrow(r), ncol(r), byrow = TRUE)
#' terra::crs(r) <- "epsg:4326"
#'
#' pal <- colorNumeric("Spectral", domain = c(0, 1000))
#' leaflet() %>% addTiles() %>%
#'   addRasterImage(r, colors = pal, opacity = 0.8) %>%
#'   addLegend(pal = pal, values = c(0, 1000))
#' }
#' @export
addRasterImage <- function(
  map,
  x,
  colors = if (is.factor(x)[1]) "Set1" else "Spectral",
  opacity = 1,
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  project = TRUE,
  method = c("auto", "bilinear", "ngb"),
  maxBytes = 4 * 1024 * 1024,
  options = gridOptions(),
  data = getMapData(map)
) {
  if (inherits(x, "SpatRaster")) {
    addRasterImage_SpatRaster(
      map = map,
      x = x,
      colors = colors,
      opacity = opacity,
      attribution = attribution,
      layerId = layerId,
      group = group,
      project = project,
      method = method,
      maxBytes = maxBytes,
      options = options,
      data = data
    )
  } else if (inherits(x, "RasterLayer")) {
    addRasterImage_RasterLayer(
      map = map,
      x = x,
      colors = colors,
      opacity = opacity,
      attribution = attribution,
      layerId = layerId,
      group = group,
      project = project,
      method = method,
      maxBytes = maxBytes,
      options = options,
      data = data
    )
  } else {
    stop("Don't know how to get path data from object of class ", class(x)[[1]])
  }
}


#' Add a color legend for a SpatRaster to a map
#'
#' A function for adding a [legend][addLegend()] that is specifically designed
#' for [terra::SpatRaster] objects, with categorical values, that carry their
#' own [color table][terra::coltab()].
#'
#' @param map a map widget object
#' @param x a [SpatRaster][terra::SpatRaster] object with a color table
#' @param layer the layer of the raster to target
#' @param ... additional arguments to pass through to [addLegend()]
#' @seealso [addRasterImage()]
#' @examplesIf interactive() && rlang::is_installed("terra")
#'
#' library(terra)
#'
#' r <- rast("/vsicurl/https://geodata.ucdavis.edu/test/pr_nlcd.tif")
#' leaflet() %>%
#'   addTiles() %>%
#'   addRasterImage(r, opacity = 0.75) %>%
#'   addRasterLegend(r, opacity = 0.75)
#'
#' plot.new() # pause in interactive mode
#'
#' rr <- r
#' levels(rr)  <- NULL
#' leaflet() %>%
#'   addTiles() %>%
#'   addRasterImage(rr, opacity = 0.75) %>%
#'   addRasterLegend(rr, opacity = 0.75)
#'
#' @export
addRasterLegend <- function(map, x, layer = 1, ...) {
  stopifnot(inherits(x, "SpatRaster"))
  rlang::check_installed("terra (>= 1.6-3)")
  stopifnot(length(layer) == 1 && layer > 0 && layer <= terra::nlyr(x))

  # might as well do this here and only once. Subsetting would otherwise have
  # been necessary in
  # color_info <- base::subset(color_info, value %in% terra::values(x))
  x <- x[[layer]]

  # Retrieve the color table from the layer. If one doesn't exist, that means
  # the raster was colored some other way, like using colorFactor or something,
  # and the regular addLegend() is designed for those cases.
  ct <- terra::coltab(x)[[1]]
  if (is.null(ct)) {
    stop(
      "addRasterLegend() can only be used on layers with color tables (see ?terra::coltab). Otherwise, use addLegend()."
    )
  }

  # Create a data frame that has value and color columns
  # Extract the colors in #RRGGBBAA format
  color_info <- data.frame(
    value = ct[[1]],
    color = grDevices::rgb(
      ct$red / 255,
      ct$green / 255,
      ct$blue / 255,
      ct$alpha / 255
    )
  )

  lvls <- terra::levels(x)[[1]]

  # Drop values that aren't part of the layer unlike "values",  "unique" is
  # memory-safe; it does not load all values into memory if the raster is large.
  # So instead of:
  #
  #  color_info <- base::subset(color_info, value %in% terra::values(x))
  #
  # remove the levels to get the raw cell values
  levels(x) <- NULL
  value_in_layer <- color_info$value %in% terra::unique(x)[[1]]
  color_info <- color_info[value_in_layer & !is.na(value_in_layer), ]

  res <- if (is.data.frame(lvls)) {
    # Use the labels from levels(x), and look up the matching colors.
    # The levels data frame can have varying colnames, just normalize them
    colnames(lvls) <- c("value", "label")
    base::merge(color_info, lvls, by.x = "value", by.y = 1)
  } else {
    # No level labels provided; use the values as labels
    cbind(color_info, label = color_info$value)
  }

  # At this point, res is a data frame with `value`, `color`, and `label` cols,
  # and values/colors not present in the raster layer have been dropped

  addLegend(map, colors = res[["color"]], labels = res[["label"]], ...)
}


addRasterImage_RasterLayer <- function(
  map,
  x,
  colors = if (is.factor(x)[1]) "Set1" else "Spectral",
  opacity = 1,
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  project = TRUE,
  method = c("auto", "bilinear", "ngb"),
  maxBytes = 4 * 1024 * 1024,
  options = gridOptions(),
  data = getMapData(map)
) {
  rlang::check_installed("raster")

  options$opacity <- opacity
  options$attribution <- attribution

  raster_is_factor <- raster::is.factor(x)
  method <- match.arg(method)
  if (method == "auto") {
    if (raster_is_factor) {
      method <- "ngb"
    } else {
      method <- "bilinear"
    }
  }

  if (project) {
    # if we should project the data
    projected <- projectRasterForLeaflet(x, method)
  } else {
    # do not project data
    projected <- x
  }

  bounds <- raster::extent(
    raster::projectExtent(
      raster::projectExtent(x, crs = raster::crs(epsg3857)),
      crs = raster::crs(epsg4326)
    )
  )

  if (!is.function(colors)) {
    if (method == "ngb") {
      # 'factors'
      colors <- colorFactor(
        colors,
        domain = NULL,
        na.color = "#00000000",
        alpha = TRUE
      )
    } else {
      # 'numeric'
      colors <- colorNumeric(
        colors,
        domain = NULL,
        na.color = "#00000000",
        alpha = TRUE
      )
    }
  }

  tileData <- raster::values(projected) %>%
    colors() %>%
    col2rgb(alpha = TRUE) %>%
    as.raw()
  dim(tileData) <- c(4, ncol(projected), nrow(projected))
  pngData <- png::writePNG(tileData)
  if (length(pngData) > maxBytes) {
    stop(
      "Raster image too large; ",
      length(pngData),
      " bytes is greater than maximum ",
      maxBytes,
      " bytes"
    )
  }
  uri <- xfun::base64_uri(pngData, "image/png")

  latlng <- list(
    list(raster::ymax(bounds), raster::xmin(bounds)),
    list(raster::ymin(bounds), raster::xmax(bounds))
  )

  invokeMethod(
    map,
    data,
    "addRasterImage",
    uri,
    latlng,
    layerId,
    group,
    options
  ) %>%
    expandLimits(
      c(raster::ymin(bounds), raster::ymax(bounds)),
      c(raster::xmin(bounds), raster::xmax(bounds))
    )
}

addRasterImage_SpatRaster <- function(
  map,
  x,
  colors = if (terra::is.factor(x)[1]) "Set1" else "Spectral",
  opacity = 1,
  attribution = NULL,
  layerId = NULL,
  group = NULL,
  project = TRUE,
  method = c("auto", "bilinear", "ngb"),
  maxBytes = 4 * 1024 * 1024,
  options = gridOptions(),
  data = getMapData(map)
) {
  rlang::check_installed(
    "terra (>= 1.6-3)",
    reason = "to use addRasterImage() for SpatRaster objects."
  ) # for terra::has.RGB()

  options$opacity <- opacity
  options$attribution <- attribution

  if (terra::has.RGB(x)) {
    # RGB(A) channels to color table
    x <- terra::colorize(x, "col")
  } else if (terra::nlyr(x) > 1) {
    x <- x[[1]]
    warning("using the first layer in 'x'", call. = FALSE)
  }

  raster_is_factor <- terra::is.factor(x)

  # there 1.5-50 has terra::has.colors(x)
  ctab <- terra::coltab(x)[[1]]
  has_colors <- !is.null(ctab)

  method <- match.arg(method)
  if (method == "ngb") {
    method = "near"
  }
  if (method == "auto") {
    if (raster_is_factor || has_colors) {
      method <- "near"
    } else {
      method <- "bilinear"
    }
  }

  bounds <- terra::ext(
    terra::project(
      terra::project(
        terra::as.points(terra::ext(x), crs = terra::crs(x)),
        epsg3857
      ),
      epsg4326
    )
  )
  ## can't the above be simplified to this?
  #  bounds <- terra::ext(
  #    terra::project(
  #        terra::as.points(terra::ext(x), crs=terra::crs(x)),
  #        epsg4326)
  #  )

  if (project) {
    # if we should project the data
    x <- projectRasterForLeaflet(x, method)
    if (method == "bilinear") {
      has_colors <- FALSE
    }
  }

  if (!is.function(colors)) {
    if (method == "near" || has_colors) {
      # 'factors'
      domain <- NULL
      if (has_colors) {
        colors <- rgb(
          ctab[, 2],
          ctab[, 3],
          ctab[, 4],
          ctab[, 5],
          maxColorValue = 255
        )
        domain <- ctab[, 1]
      }
      colors <- colorFactor(
        colors,
        domain = domain,
        na.color = "#00000000",
        alpha = TRUE
      )
    } else {
      # 'numeric'
      colors <- colorNumeric(
        colors,
        domain = NULL,
        na.color = "#00000000",
        alpha = TRUE
      )
    }
  }

  tileData <- terra::values(x) %>%
    as.vector() %>%
    colors() %>%
    col2rgb(alpha = TRUE) %>%
    as.raw()
  dim(tileData) <- c(4, ncol(x), nrow(x))
  pngData <- png::writePNG(tileData)
  if (length(pngData) > maxBytes) {
    stop(
      "Raster image too large; ",
      length(pngData),
      " bytes is greater than maximum ",
      maxBytes,
      " bytes"
    )
  }
  uri <- xfun::base64_uri(pngData, "image/png")

  latlng <- list(
    list(terra::ymax(bounds), terra::xmin(bounds)),
    list(terra::ymin(bounds), terra::xmax(bounds))
  )

  invokeMethod(
    map,
    data,
    "addRasterImage",
    uri,
    latlng,
    layerId,
    group,
    options
  ) %>%
    expandLimits(
      c(terra::ymin(bounds), terra::ymax(bounds)),
      c(terra::xmin(bounds), terra::xmax(bounds))
    )
}


#' @rdname addRasterImage
#' @export
projectRasterForLeaflet <- function(x, method) {
  if (inherits(x, "SpatRaster")) {
    rlang::check_installed("terra (>= 1.6-3)")
    if (method == "ngb") {
      method = "near"
    }
    terra::project(
      x,
      y = epsg3857,
      method = method
    )
  } else {
    rlang::check_installed("raster")
    raster_is_factor <- raster::is.factor(x)
    projected <- raster::projectRaster(
      x,
      raster::projectExtent(x, crs = raster::crs(epsg3857)),
      method = method
    )
    # if data is factor data, make the result factors as well.
    # only meaningful if ngb was used
    if ((raster_is_factor) && (method == "ngb")) {
      raster::as.factor(projected)
    } else {
      projected
    }
  }
}

#' @rdname remove
#' @export
removeImage <- function(map, layerId) {
  invokeMethod(map, NULL, "removeImage", layerId)
}

#' @rdname remove
#' @export
clearImages <- function(map) {
  invokeMethod(map, NULL, "clearImages")
}

#' Extra options for map elements and layers
#'
#' The rest of all possible options for map elements and layers that are not
#' listed in the layer functions.
#' @param
#' minZoom,maxZoom,maxNativeZoom,tileSize,subdomains,errorTileUrl,tms,noWrap,zoomOffset,zoomReverse,zIndex,unloadInvisibleTiles,updateWhenIdle,detectRetina
#' the tile layer options; see
#' <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#tilelayer>
#' @param ... extra options passed to underlying JavaScript object constructor.
#' @describeIn map-options Options for tile layers
#' @export
tileOptions <- function(
  minZoom = 0,
  maxZoom = 18,
  maxNativeZoom = NULL,
  tileSize = 256,
  subdomains = "abc",
  errorTileUrl = "",
  tms = FALSE,
  noWrap = FALSE,
  zoomOffset = 0,
  zoomReverse = FALSE,
  opacity = 1.0,
  zIndex = 1,
  unloadInvisibleTiles = NULL,
  updateWhenIdle = NULL,
  detectRetina = FALSE,
  ...
) {
  filterNULL(list(
    minZoom = minZoom,
    maxZoom = maxZoom,
    maxNativeZoom = maxNativeZoom,
    tileSize = tileSize,
    subdomains = subdomains,
    errorTileUrl = errorTileUrl,
    tms = tms,
    noWrap = noWrap,
    zoomOffset = zoomOffset,
    zoomReverse = zoomReverse,
    opacity = opacity,
    zIndex = zIndex,
    unloadInvisibleTiles = unloadInvisibleTiles,
    updateWhenIdle = updateWhenIdle,
    detectRetina = detectRetina,
    ...
  ))
}

#' @describeIn map-options Options for grid layers
#' @export
gridOptions <- function(
  tileSize = 256,
  updateWhenIdle = NULL,
  zIndex = 1,
  minZoom = 0,
  maxZoom = NULL,
  ...
) {
  filterNULL(list(
    tileSize = tileSize,
    updateWhenIdle = updateWhenIdle,
    zIndex = zIndex,
    minZoom = minZoom,
    maxZoom = maxZoom,
    ...
  ))
}

#' Remove elements from a map
#'
#' Remove one or more features from a map, identified by `layerId`; or,
#' clear all features of the given type or group.
#'
#' @note When used with a [leaflet][leaflet()] map object, these functions
#'   don't actually remove the features from the map object, but simply add an
#'   operation that will cause those features to be removed after they are
#'   added. In other words, if you add a polygon `"foo"` and the call
#'   `removeShape("foo")`, it's not smart enough to prevent the polygon
#'   from being added in the first place; instead, when the map is rendered, the
#'   polygon will be added and then removed.
#'
#'   For that reason, these functions aren't that useful with `leaflet` map
#'   objects and are really intended to be used with [leafletProxy()]
#'   instead.
#'
#'   WMS tile layers are extensions of tile layers, so they can also be removed
#'   or cleared via `removeTiles()` or `clearTiles()`.
#' @param map a map widget object, possibly created from [leaflet()]
#'   but more likely from [leafletProxy()]
#' @param layerId character vector; the layer id(s) of the item to remove
#' @return the new `map` object
#'
#' @name remove
#' @export
removeTiles <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeTiles", layerId)
}

#' @rdname remove
#' @export
clearTiles <- function(map) {
  invokeMethod(map, NULL, "clearTiles")
}


#' @param baseUrl a base URL of the WMS service
#' @param layers comma-separated list of WMS layers to show
#' @describeIn map-layers Add a WMS tile layer to the map
#' @export
addWMSTiles <- function(
  map,
  baseUrl,
  layerId = NULL,
  group = NULL,
  options = WMSTileOptions(),
  attribution = NULL,
  layers = "",
  data = getMapData(map)
) {
  if (identical(layers, "")) {
    stop(
      "layers is a required argument with comma-separated list of WMS layers to show"
    )
  }
  options$attribution <- attribution
  options$layers <- layers
  invokeMethod(map, data, "addWMSTiles", baseUrl, layerId, group, options)
}

#' @param styles comma-separated list of WMS styles
#' @param format WMS image format (use `"image/png"` for layers with
#'   transparency)
#' @param transparent if `TRUE`, the WMS service will return images with
#'   transparency
#' @param version version of the WMS service to use
#' @param crs Coordinate Reference System to use for the WMS requests, defaults.
#' @seealso [leafletCRS()]
#'   to map CRS (don't change this if you're not sure what it means)
#' @describeIn map-options Options for WMS tile layers
#' @export
WMSTileOptions <- function(
  styles = "",
  format = "image/jpeg",
  transparent = FALSE,
  version = "1.1.1",
  crs = NULL,
  ...
) {
  filterNULL(list(
    styles = styles,
    format = format,
    transparent = transparent,
    version = version,
    crs = crs,
    ...
  ))
}

#' @param lng a numeric vector of longitudes, or a one-sided formula of the form
#'   `~x` where `x` is a variable in `data`; by default (if not
#'   explicitly provided), it will be automatically inferred from `data` by
#'   looking for a column named `lng`, `long`, or `longitude`
#'   (case-insensitively)
#' @param lat a vector of latitudes or a formula (similar to the `lng`
#'   argument; the names `lat` and `latitude` are used when guessing
#'   the latitude column from `data`)
#' @param popup a character vector of the HTML content for the popups (you are
#'   recommended to escape the text using [htmltools::htmlEscape()]
#'   for security reasons)
#' @param popupOptions A Vector of [popupOptions()] to provide popups
#' @param layerId the layer id
#' @param group the name of the group the newly created layers should belong to
#'   (for [clearGroup()] and [addLayersControl()] purposes).
#'   Human-friendly group names are permitted--they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g., markers and polygons) can share the same group name.
#' @template data-getMapData
#' @describeIn map-layers Add popups to the map
#' @export
addPopups <- function(
  map,
  lng = NULL,
  lat = NULL,
  popup,
  layerId = NULL,
  group = NULL,
  options = popupOptions(),
  data = getMapData(map)
) {
  pts <- derivePoints(data, lng, lat, missing(lng), missing(lat), "addPopups")
  invokeMethod(
    map,
    data,
    "addPopups",
    pts$lat,
    pts$lng,
    popup,
    layerId,
    group,
    options
  ) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @param className a CSS class name set on an element
#' @param
#' maxWidth,minWidth,maxHeight,autoPan,keepInView,closeButton,closeOnClick
#' popup options; see <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#popup-option>
#' @describeIn map-options Options for popups
#' @export
popupOptions <- function(
  maxWidth = 300,
  minWidth = 50,
  maxHeight = NULL,
  autoPan = TRUE,
  keepInView = FALSE,
  closeButton = TRUE,
  zoomAnimation = NULL,
  closeOnClick = NULL,
  className = "",
  ...
) {
  if (!missing(zoomAnimation)) {
    zoomAnimationWarning()
  }
  filterNULL(list(
    maxWidth = maxWidth,
    minWidth = minWidth,
    maxHeight = maxHeight,
    autoPan = autoPan,
    keepInView = keepInView,
    closeButton = closeButton,
    closeOnClick = closeOnClick,
    className = className,
    ...
  ))
}

#' @rdname remove
#' @export
removePopup <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removePopup", layerId)
}

#' @rdname remove
#' @export
clearPopups <- function(map) {
  invokeMethod(map, NULL, "clearPopups")
}

#' Sanitize textual labels
#'
#' This is a helper function used internally to HTML-escape user-provided
#' labels. It prevents strings from unintentionally being treated as HTML when
#' they are intended to be plaintext.
#'
#' @param label A vector or list of plain characters or HTML (marked by
#'   [htmltools::HTML()]), or a formula that resolves to such a value.
#' @param data A data frame over which the formula is evaluated.
#'
#' @keywords internal
#' @export
safeLabel <- function(label, data) {
  if (is.null(label)) {
    return(label)
  }

  label <- evalFormula(label, data)
  if (
    !(
      inherits(label, "html") ||
        sum(sapply(label, function(x) {
          !inherits(x, "html")
        })) ==
          0 # nolint
    )
  ) {
    label <- htmltools::htmlEscape(label)
  }
  label
}

#' @param
#' noHide,direction,offset,permanent
#' label options; see <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#tooltip-option>
#' @param opacity Tooltip container opacity. Ranges from 0 to 1. Default value is `1` (different from leaflet.js `0.9`); see <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#tooltip-opacity>
#' @param textsize Change the text size of a single tooltip
#' @param textOnly Display only the text, no regular surrounding box.
#' @param style list of css style to be added to the tooltip
#' @param zoomAnimation deprecated. See <https://github.com/Leaflet/Leaflet/blob/master/CHANGELOG.md#api-changes-5>
#' @param sticky If true, the tooltip will follow the mouse instead of being fixed at the feature center. Default value is `TRUE` (different from leaflet.js `FALSE`); see <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#tooltip-sticky>
#' @describeIn map-options Options for labels
#' @export
labelOptions <- function(
  interactive = FALSE,
  clickable = NULL,
  noHide = NULL,
  permanent = FALSE,
  className = "",
  direction = "auto",
  offset = c(0, 0),
  opacity = 1,
  textsize = "10px",
  textOnly = FALSE,
  style = NULL,
  zoomAnimation = NULL,
  sticky = TRUE,
  ...
) {
  # use old (Leaflet 0.7.x) clickable if provided
  if (!is.null(clickable) && interactive != clickable) {
    interactive <- clickable
  }
  # use old noHide if provided
  if (!is.null(noHide) && permanent != noHide) {
    permanent <- noHide
  }
  if (!missing(zoomAnimation)) {
    zoomAnimationWarning()
  }

  filterNULL(list(
    interactive = interactive,
    permanent = permanent,
    direction = direction,
    opacity = opacity,
    offset = offset,
    textsize = textsize,
    textOnly = textOnly,
    style = style,
    className = className,
    sticky = sticky,
    ...
  ))
}

#' @param icon the icon(s) for markers; an icon is represented by an R list of
#'   the form `list(iconUrl = "?", iconSize = c(x, y))`, and you can use
#'   [icons()] to create multiple icons; note when you use an R list
#'   that contains images as local files, these local image files will be base64
#'   encoded into the HTML page so the icon images will still be available even
#'   when you publish the map elsewhere
#' @param label a character vector of the HTML content for the labels
#' @param labelOptions A Vector of [labelOptions()] to provide label
#' options for each label. Default `NULL`
#' @param clusterOptions if not `NULL`, markers will be clustered using
#'   [Leaflet.markercluster](https://github.com/Leaflet/Leaflet.markercluster);
#'    you can use [markerClusterOptions()] to specify marker cluster
#'   options
#' @param clusterId the id for the marker cluster layer
#' @describeIn map-layers Add markers to the map
#' @export
addMarkers <- function(
  map,
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
  icon = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  if (!is.null(icon)) {
    # If custom icons are specified, we need to 1) deduplicate any URLs/files,
    # so we can efficiently send e.g., 1000 markers that all use the same 2
    # icons; and 2) do base64 encoding on any local icon files (as opposed to
    # URLs [absolute or relative] which will be left alone).

    # If formulas are present, they must be evaluated first so we can pack the
    # resulting values
    icon <- evalFormula(list(icon), data)[[1]]

    if (inherits(icon, "leaflet_icon_set")) {
      icon <- iconSetToIcons(icon)
    }

    # Pack and encode each URL vector; this will be reversed on the client
    icon$iconUrl <- b64EncodePackedIcons(packStrings(icon$iconUrl))
    icon$iconRetinaUrl <- b64EncodePackedIcons(packStrings(icon$iconRetinaUrl))
    icon$shadowUrl <- b64EncodePackedIcons(packStrings(icon$shadowUrl))
    icon$shadowRetinaUrl <- b64EncodePackedIcons(packStrings(
      icon$shadowRetinaUrl
    ))

    # if iconSize is of length 2 and there is one icon url, wrap the icon size in a list
    if (length(icon$iconSize) == 2) {
      if (is.numeric(icon$iconSize[[1]]) && is.numeric(icon$iconSize[[2]])) {
        icon$iconSize <- list(icon$iconSize)
      }
    }

    icon <- filterNULL(icon)
  }

  if (!is.null(clusterOptions)) {
    map$dependencies <- c(map$dependencies, markerClusterDependencies())
  }

  pts <- derivePoints(data, lng, lat, missing(lng), missing(lat), "addMarkers")
  invokeMethod(
    map,
    data,
    "addMarkers",
    pts$lat,
    pts$lng,
    icon,
    layerId,
    group,
    options,
    popup,
    popupOptions,
    clusterOptions,
    clusterId,
    safeLabel(label, data),
    labelOptions,
    getCrosstalkOptions(data)
  ) %>%
    expandLimits(pts$lat, pts$lng)
}

getCrosstalkOptions <- function(data) {
  if (is.SharedData(data)) {
    list(ctKey = data$key(), ctGroup = data$groupName())
  } else {
    NULL
  }
}

#' @describeIn map-layers Add Label only markers to the map
#' @export
addLabelOnlyMarkers <- function(
  map,
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
  icon = NULL,
  label = NULL,
  labelOptions = NULL,
  options = markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  do.call(
    addMarkers,
    filterNULL(list(
      map = map,
      lng = lng,
      lat = lat,
      layerId = layerId,
      group = group,
      icon = makeIcon(
        iconUrl = system_file(
          "htmlwidgets/lib/rstudio_leaflet/images/1px.png",
          package = "leaflet"
        ),
        iconWidth = 1,
        iconHeight = 1
      ),
      label = label,
      labelOptions = labelOptions,
      options = options,
      clusterOptions = clusterOptions,
      clusterId = clusterId,
      data = data
    ))
  )
}

# Adds marker-cluster-plugin HTML dependency
markerClusterDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-markercluster",
      "1.0.5",
      "htmlwidgets/plugins/Leaflet.markercluster",
      package = "leaflet",
      script = c(
        "leaflet.markercluster.js",
        "leaflet.markercluster.freezable.js",
        "leaflet.markercluster.layersupport.js"
      ),
      stylesheet = c("MarkerCluster.css", "MarkerCluster.Default.css")
    )
  )
}

#' Make icon set
#'
#' @param ... icons created from [makeIcon()]
#' @export
#' @examples
#'
#' iconSet <- iconList(
#'   red = makeIcon("leaf-red.png", iconWidth = 32, iconHeight = 32),
#'   green = makeIcon("leaf-green.png", iconWidth = 32, iconHeight = 32)
#' )
#'
#' iconSet[c("red", "green", "red")]
iconList <- function(...) {
  res <- structure(
    list(...),
    class = "leaflet_icon_set"
  )
  cls <- unlist(lapply(res, inherits, "leaflet_icon"))
  if (any(!cls)) {
    stop(
      "Arguments passed to iconList() must be icon objects returned from makeIcon()"
    )
  }
  res
}

#' @export
`[.leaflet_icon_set` <- function(x, i) {
  if (is.factor(i)) {
    i <- as.character(i)
  }

  if (!is.character(i) && !is.numeric(i) && !is.integer(i)) {
    stop("Invalid subscript type '", typeof(i), "'")
  }

  structure(.subset(x, i), class = "leaflet_icon_set")
}

iconSetToIcons <- function(x) {
  # c("iconUrl", "iconRetinaUrl", ...)
  cols <- names(formals(makeIcon))
  # list(iconUrl = "iconUrl", iconRetinaUrl = "iconRetinaUrl", ...)
  cols <- structure(as.list(cols), names = cols)

  # Construct an equivalent output to icons().
  filterNULL(lapply(cols, function(col) {
    # Pluck the `col` member off of each item in iconObjs and put them in an
    # unnamed list (or vector if possible).
    colVals <- unname(sapply(x, `[[`, col))

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
makeIcon <- function(
  iconUrl = NULL,
  iconRetinaUrl = NULL,
  iconWidth = NULL,
  iconHeight = NULL,
  iconAnchorX = NULL,
  iconAnchorY = NULL,
  shadowUrl = NULL,
  shadowRetinaUrl = NULL,
  shadowWidth = NULL,
  shadowHeight = NULL,
  shadowAnchorX = NULL,
  shadowAnchorY = NULL,
  popupAnchorX = NULL,
  popupAnchorY = NULL,
  className = NULL
) {
  icon <- filterNULL(list(
    iconUrl = iconUrl,
    iconRetinaUrl = iconRetinaUrl,
    iconWidth = iconWidth,
    iconHeight = iconHeight,
    iconAnchorX = iconAnchorX,
    iconAnchorY = iconAnchorY,
    shadowUrl = shadowUrl,
    shadowRetinaUrl = shadowRetinaUrl,
    shadowWidth = shadowWidth,
    shadowHeight = shadowHeight,
    shadowAnchorX = shadowAnchorX,
    shadowAnchorY = shadowAnchorY,
    popupAnchorX = popupAnchorX,
    popupAnchorY = popupAnchorY,
    className = className
  ))
  structure(icon, class = "leaflet_icon")
}

#' Create a list of icon data
#'
#' An icon can be represented as a list of the form `list(iconUrl,
#' iconSize, ...)`. This function is vectorized over its arguments to create a
#' list of icon data. Shorter argument values will be re-cycled. `NULL`
#' values for these arguments will be ignored.
#' @param iconUrl the URL or file path to the icon image
#' @param iconRetinaUrl the URL or file path to a retina sized version of the
#'   icon image
#' @param iconWidth,iconHeight size of the icon image in pixels
#' @param iconAnchorX,iconAnchorY the coordinates of the "tip" of the icon
#'   (relative to its top left corner, i.e., the top left corner means
#'   `iconAnchorX = 0` and `iconAnchorY = 0`), and the icon will be
#'   aligned so that this point is at the marker's geographical location
#' @param shadowUrl the URL or file path to the icon shadow image
#' @param shadowRetinaUrl the URL or file path to the retina sized version of
#'   the icon shadow image
#' @param shadowWidth,shadowHeight size of the shadow image in pixels
#' @param shadowAnchorX,shadowAnchorY the coordinates of the "tip" of the shadow
#' @param popupAnchorX,popupAnchorY the coordinates of the point from which
#'   popups will "open", relative to the icon anchor
#' @param className a custom class name to assign to both icon and shadow images
#' @return A list of icon data that can be passed to the `icon` argument of
#'   [addMarkers()].
#' @export
#' @example inst/examples/icons.R
icons <- function(
  iconUrl = NULL,
  iconRetinaUrl = NULL,
  iconWidth = NULL,
  iconHeight = NULL,
  iconAnchorX = NULL,
  iconAnchorY = NULL,
  shadowUrl = NULL,
  shadowRetinaUrl = NULL,
  shadowWidth = NULL,
  shadowHeight = NULL,
  shadowAnchorX = NULL,
  shadowAnchorY = NULL,
  popupAnchorX = NULL,
  popupAnchorY = NULL,
  className = NULL
) {
  filterNULL(list(
    iconUrl = iconUrl,
    iconRetinaUrl = iconRetinaUrl,
    iconWidth = iconWidth,
    iconHeight = iconHeight,
    iconAnchorX = iconAnchorX,
    iconAnchorY = iconAnchorY,
    shadowUrl = shadowUrl,
    shadowRetinaUrl = shadowRetinaUrl,
    shadowWidth = shadowWidth,
    shadowHeight = shadowHeight,
    shadowAnchorX = shadowAnchorX,
    shadowAnchorY = shadowAnchorY,
    popupAnchorX = popupAnchorX,
    popupAnchorY = popupAnchorY,
    className = className
  ))
}

packStrings <- function(strings) {
  if (length(strings) == 0) {
    return(NULL)
  }
  uniques <- unique(strings)
  indices <- match(strings, uniques)
  indices <- indices - 1 # convert to 0-based for easy JS usage

  list(
    data = uniques,
    index = indices
  )
}

b64EncodePackedIcons <- function(packedIcons) {
  if (is.null(packedIcons)) {
    return(packedIcons)
  }

  packedIcons$data <- sapply(
    packedIcons$data,
    function(icon) {
      if (is.character(icon) && file.exists(icon)) {
        xfun::base64_uri(icon)
      } else {
        icon
      }
    },
    USE.NAMES = FALSE
  ) # nolint
  packedIcons
}

#' @param interactive whether the element emits mouse events
#' @param clickable DEPRECATED! Use the `interactive` argument.
#' @param
#'   draggable,keyboard,title,alt,zIndexOffset,riseOnHover,riseOffset
#'   marker options; see <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#marker-option>
#' @describeIn map-options Options for markers
#' @export
markerOptions <- function(
  interactive = TRUE,
  clickable = NULL,
  draggable = FALSE,
  keyboard = TRUE,
  title = "",
  alt = "",
  zIndexOffset = 0,
  opacity = 1.0,
  riseOnHover = FALSE,
  riseOffset = 250,
  ...
) {
  # use old (Leaflet 0.7.x) clickable if provided
  if (!is.null(clickable) && interactive != clickable) {
    interactive <- clickable
  }

  filterNULL(list(
    interactive = interactive,
    draggable = draggable,
    keyboard = keyboard,
    title = title,
    alt = alt,
    zIndexOffset = zIndexOffset,
    opacity = opacity,
    riseOnHover = riseOnHover,
    riseOffset = riseOffset,
    ...
  ))
}

#' @param showCoverageOnHover when you mouse over a cluster it shows the bounds
#'   of its markers
#' @param zoomToBoundsOnClick when you click a cluster we zoom to its bounds
#' @param spiderfyOnMaxZoom when you click a cluster at the bottom zoom level we
#'   spiderfy it so you can see all of its markers
#' @param removeOutsideVisibleBounds clusters and markers too far from the
#'   viewport are removed from the map for performance
#' @param spiderLegPolylineOptions Allows you to specify
#'   [PolylineOptions](https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#polyline-option)
#'   to style spider legs. By default, they are
#'   \code{\{weight: 1.5, color: "#222", opacity: 0.5 \}}.
#' @param freezeAtZoom Allows you to freeze cluster expansion to a zoom level.
#'   Can be a zoom level e.g., 10, 12 or "max" or "maxKeepSpiderify".
#'   See <https://github.com/ghybs/Leaflet.MarkerCluster.Freezable#api-reference>.
#' @describeIn map-options Options for marker clusters
#' @export
markerClusterOptions <- function(
  showCoverageOnHover = TRUE,
  zoomToBoundsOnClick = TRUE,
  spiderfyOnMaxZoom = TRUE,
  removeOutsideVisibleBounds = TRUE,
  spiderLegPolylineOptions = list(weight = 1.5, color = "#222", opacity = 0.5),
  freezeAtZoom = FALSE,
  ...
) {
  filterNULL(list(
    showCoverageOnHover = showCoverageOnHover,
    zoomToBoundsOnClick = zoomToBoundsOnClick,
    spiderfyOnMaxZoom = spiderfyOnMaxZoom,
    removeOutsideVisibleBounds = removeOutsideVisibleBounds,
    spiderLegPolylineOptions = spiderLegPolylineOptions,
    freezeAtZoom = freezeAtZoom,
    ...
  ))
}

#' @param radius a numeric vector of radii for the circles; it can also be a
#'   one-sided formula, in which case the radius values are derived from the
#'   `data` (units in meters for circles, and pixels for circle markers)
#' @param stroke whether to draw stroke along the path (e.g., the borders of
#'   polygons or circles)
#' @param color stroke color
#' @param weight stroke width in pixels
#' @param opacity stroke opacity (or layer opacity for tile layers)
#' @param fill whether to fill the path with color (e.g., filling on polygons or
#'   circles)
#' @param fillColor fill color
#' @param fillOpacity fill opacity
#' @param dashArray a string that defines the stroke [dash
#'   pattern](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
#' @describeIn map-layers Add circle markers to the map
#' @export
addCircleMarkers <- function(
  map,
  lng = NULL,
  lat = NULL,
  radius = 10,
  layerId = NULL,
  group = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = pathOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray
    ))
  )
  if (!is.null(clusterOptions)) {
    map$dependencies <- c(map$dependencies, markerClusterDependencies())
  }
  pts <- derivePoints(
    data,
    lng,
    lat,
    missing(lng),
    missing(lat),
    "addCircleMarkers"
  )
  invokeMethod(
    map,
    data,
    "addCircleMarkers",
    pts$lat,
    pts$lng,
    radius,
    layerId,
    group,
    options,
    clusterOptions,
    clusterId,
    popup,
    popupOptions,
    safeLabel(label, data),
    labelOptions,
    getCrosstalkOptions(data)
  ) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @rdname remove
#' @export
removeMarker <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeMarker", layerId)
}

#' @rdname remove
#' @export
clearMarkers <- function(map) {
  invokeMethod(map, NULL, "clearMarkers")
}

#' @rdname remove
#' @export
removeMarkerCluster <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeMarkerCluster", layerId)
}

#' @rdname remove
#' @export
clearMarkerClusters <- function(map) {
  invokeMethod(map, NULL, "clearMarkerClusters")
}

#' @param clusterId the id of the marker cluster layer
#' @rdname remove
#' @export
removeMarkerFromCluster <- function(map, layerId, clusterId) {
  invokeMethod(
    map,
    getMapData(map),
    "removeMarkerFromCluster",
    layerId,
    clusterId
  )
}

#' @param lineCap a string that defines [shape to be used
#'   at the end](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linecap)
#'   of the stroke.
#' @param lineJoin a string that defines [shape to be used at the
#'   corners](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linejoin)
#'   of the stroke.
#' @param pointerEvents sets the `pointer-events` attribute on the path if
#'   SVG backend is used
#' @describeIn map-options Options for vector layers (polylines, polygons,
#'   rectangles, and circles, etc)
#' @export
pathOptions <- function(
  lineCap = NULL,
  lineJoin = NULL,
  clickable = NULL,
  interactive = TRUE,
  pointerEvents = NULL,
  className = "",
  ...
) {
  # use old (Leaflet 0.7.x) clickable if provided
  if (!is.null(clickable) && interactive != clickable) {
    interactive <- clickable
  }
  filterNULL(list(
    lineCap = lineCap,
    lineJoin = lineJoin,
    interactive = interactive,
    pointerEvents = pointerEvents,
    className = className,
    ...
  ))
}

#' Options to highlight shapes (polylines/polygons/circles/rectangles)
#' @param bringToFront Whether the shape should be brought to front on hover.
#' @param sendToBack whether the shape should be sent to back on mouse out.
#' @describeIn map-layers Options to highlight a shape on hover
#' @export
highlightOptions <- function(
  stroke = NULL,
  color = NULL,
  weight = NULL,
  opacity = NULL,
  fill = NULL,
  fillColor = NULL,
  fillOpacity = NULL,
  dashArray = NULL,
  bringToFront = NULL,
  sendToBack = NULL
) {
  filterNULL(list(
    stroke = stroke,
    color = color,
    weight = weight,
    opacity = opacity,
    fill = fill,
    fillColor = fillColor,
    fillOpacity = fillOpacity,
    dashArray = dashArray,
    bringToFront = bringToFront,
    sendToBack = sendToBack
  ))
}

#' @describeIn map-layers Add circles to the map
#' @export
addCircles <- function(
  map,
  lng = NULL,
  lat = NULL,
  radius = 10,
  layerId = NULL,
  group = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = pathOptions(),
  highlightOptions = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray
    ))
  )
  pts <- derivePoints(data, lng, lat, missing(lng), missing(lat), "addCircles")
  invokeMethod(
    map,
    data,
    "addCircles",
    pts$lat,
    pts$lng,
    radius,
    layerId,
    group,
    options,
    popup,
    popupOptions,
    safeLabel(label, data),
    labelOptions,
    highlightOptions,
    getCrosstalkOptions(data)
  ) %>%
    expandLimits(pts$lat, pts$lng)
}

#' @param smoothFactor how much to simplify the polyline on each zoom level
#'   (more means better performance and less accurate representation)
#' @param highlightOptions Options for highlighting the shape on mouse over.
#' @param noClip whether to disable polyline clipping
#' @describeIn map-layers Add polylines to the map
#' @export
addPolylines <- function(
  map,
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
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
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = pathOptions(),
  highlightOptions = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray,
      smoothFactor = smoothFactor,
      noClip = noClip
    ))
  )
  pgons <- derivePolygons(
    data,
    lng,
    lat,
    missing(lng),
    missing(lat),
    "addPolylines"
  )
  invokeMethod(
    map,
    data,
    "addPolylines",
    pgons,
    layerId,
    group,
    options,
    popup,
    popupOptions,
    safeLabel(label, data),
    labelOptions,
    highlightOptions
  ) %>%
    expandLimitsBbox(pgons)
}

#' @param lng1,lat1,lng2,lat2 latitudes and longitudes of the south-west and
#'   north-east corners of rectangles
#' @describeIn map-layers Add rectangles to the map
#' @export
addRectangles <- function(
  map,
  lng1,
  lat1,
  lng2,
  lat2,
  layerId = NULL,
  group = NULL,
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
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = pathOptions(),
  highlightOptions = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray,
      smoothFactor = smoothFactor,
      noClip = noClip
    ))
  )
  lng1 <- resolveFormula(lng1, data)
  lat1 <- resolveFormula(lat1, data)
  lng2 <- resolveFormula(lng2, data)
  lat2 <- resolveFormula(lat2, data)

  df1 <- validateCoords(lng1, lat1, "addRectangles")
  df2 <- validateCoords(lng2, lat2, "addRectangles")

  invokeMethod(
    map,
    data,
    "addRectangles",
    df1$lat,
    df1$lng,
    df2$lat,
    df2$lng,
    layerId,
    group,
    options,
    popup,
    popupOptions,
    safeLabel(label, data),
    labelOptions,
    highlightOptions
  ) %>%
    expandLimits(c(lat1, lat2), c(lng1, lng2))
}

#' @describeIn map-layers Add polygons to the map
#' @export
addPolygons <- function(
  map,
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
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
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = pathOptions(),
  highlightOptions = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) {
    labelOptions <- labelOptions()
  }

  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray,
      smoothFactor = smoothFactor,
      noClip = noClip
    ))
  )
  pgons <- derivePolygons(
    data,
    lng,
    lat,
    missing(lng),
    missing(lat),
    "addPolygons"
  )
  invokeMethod(
    map,
    data,
    "addPolygons",
    pgons,
    layerId,
    group,
    options,
    popup,
    popupOptions,
    safeLabel(label, data),
    labelOptions,
    highlightOptions
  ) %>%
    expandLimitsBbox(pgons)
}

#' @rdname remove
#' @export
removeShape <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeShape", layerId)
}

#' @rdname remove
#' @export
clearShapes <- function(map) {
  invokeMethod(map, NULL, "clearShapes")
}

#' @param geojson a GeoJSON list, or character vector of length 1
#' @describeIn map-layers Add GeoJSON layers to the map
#' @export
addGeoJSON <- function(
  map,
  geojson,
  layerId = NULL,
  group = NULL,
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
  options = pathOptions(),
  data = getMapData(map)
) {
  options <- c(
    options,
    filterNULL(list(
      stroke = stroke,
      color = color,
      weight = weight,
      opacity = opacity,
      fill = fill,
      fillColor = fillColor,
      fillOpacity = fillOpacity,
      dashArray = dashArray,
      smoothFactor = smoothFactor,
      noClip = noClip
    ))
  )
  invokeMethod(map, data, "addGeoJSON", geojson, layerId, group, options)
}

#' @rdname remove
#' @export
removeGeoJSON <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeGeoJSON", layerId)
}

#' @rdname remove
#' @export
clearGeoJSON <- function(map) {
  invokeMethod(map, NULL, "clearGeoJSON")
}

#' Add UI controls to switch layers on and off
#'
#' Uses Leaflet's built-in
#' [layers control](https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#control-layers)
#' feature to allow users to choose one of several base layers, and to choose
#' any number of overlay layers to view.
#'
#' @param map the map to add the layers control to
#' @param baseGroups character vector where each element is the name of a group.
#'   The user will be able to choose one base group (only) at a time. This is
#'   most commonly used for mostly-opaque tile layers.
#' @param overlayGroups character vector where each element is the name of a
#'   group. The user can turn each overlay group on or off independently.
#' @param position position of control: `"topleft"`, `"topright"`,
#'   `"bottomleft"`, or `"bottomright"`.
#' @param options a list of additional options, intended to be provided by
#'   a call to `layersControlOptions()`
#' @template data-getMapData
#'
#' @examples
#' \donttest{
#' leaflet() %>%
#'   addTiles(group = "OpenStreetMap") %>%
#'   addProviderTiles("CartoDB.Voyager", group = "Carto Voyager") %>%
#'   addMarkers(runif(20, -75, -74), runif(20, 41, 42), group = "Markers") %>%
#'   addLayersControl(
#'     baseGroups = c("OpenStreetMap", "Carto Voyager"),
#'     overlayGroups = c("Markers")
#'   )
#' }
#'
#' @export
addLayersControl <- function(
  map,
  baseGroups = character(0),
  overlayGroups = character(0),
  position = c("topright", "bottomright", "bottomleft", "topleft"),
  options = layersControlOptions(),
  data = getMapData(map)
) {
  options <- c(options, list(position = match.arg(position)))
  invokeMethod(
    map,
    data,
    "addLayersControl",
    baseGroups,
    overlayGroups,
    options
  )
}

#' @rdname addLayersControl
#' @param collapsed if `TRUE` (the default), the layers control will be
#'   rendered as an icon that expands when hovered over. Set to `FALSE`
#'   to have the layers control always appear in its expanded state.
#' @param autoZIndex if `TRUE`, the control will automatically maintain
#'   the z-order of its various groups as overlays are switched on and off.
#' @param ... other options for `layersControlOptions()`
#' @export
layersControlOptions <- function(collapsed = TRUE, autoZIndex = TRUE, ...) {
  filterNULL(list(collapsed = collapsed, autoZIndex = autoZIndex, ...))
}

#' @rdname addLayersControl
#' @export
removeLayersControl <- function(map) {
  invokeMethod(map, NULL, "removeLayersControl")
}


zoomAnimationWarning <- function() {
  warning(
    "zoomAnimation has been deprecated by Leaflet.js. See https://github.com/Leaflet/Leaflet/blob/master/CHANGELOG.md#api-changes-5\nignoring 'zoomAnimation' parameter"
  )
}
