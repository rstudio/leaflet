#' Create a Leaflet map widget
#'
#' This function creates a Leaflet map widget using \pkg{htmlwidgets}. The
#' widget can be rendered on HTML pages generated from R Markdown, Shiny, or
#' other applications.
#'
#' The \code{data} argument is only needed if you are going to reference
#' variables in this object later in map layers. For example, \code{data} can be
#' a data frame containing columns \code{latitude} and \code{longtitude}, then
#' we may add a circle layer to the map by \code{leaflet(data) \%>\%
#' addCircles(lat = ~latitude, lng = ~longtitude)}, where the variables in the
#' formulae will be evaluated in the \code{data}.
#' @param data a data object. Currently supported objects are matrices, data
#'   frames, spatial objects from the \pkg{sp} package
#'   (\code{SpatialPoints}, \code{SpatialPointsDataFrame}, \code{Polygon},
#'   \code{Polygons}, \code{SpatialPolygons}, \code{SpatialPolygonsDataFrame},
#'   \code{Line}, \code{Lines}, \code{SpatialLines}, and
#'   \code{SpatialLinesDataFrame}), and
#'   spatial data frames from the \pkg{sf} package.
#' @param width the width of the map
#' @param height the height of the map
#' @param padding the padding of the map
#' @param options the map options
#' @return A HTML widget object, on which we can add graphics layers using
#'   \code{\%>\%} (see examples).
#' @example inst/examples/leaflet.R
#' @export
leaflet <- function(data = NULL, width = NULL, height = NULL,
                   padding = 0, options = leafletOptions()) {

  # Validate the CRS if specified
  if(!is.null(options[['crs']]) &&
     !inherits(options[['crs']], 'leaflet_crs')) {
    stop("CRS in mapOptions should be a return value of leafletCRS() function")
  }

  map <- htmlwidgets::createWidget(
    'leaflet',
    structure(
      list(options = options),
      leafletData = data
    ),
    width = width, height = height,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = '100%',
      defaultHeight = 400,
      padding = padding,
      browser.fill = TRUE
    ),
    preRenderHook = function(widget) {
      if (!is.null(widget$jsHooks$render)) {
        widget$jsHooks$render <- lapply(widget$jsHooks$render, function(hook) {
          if (is.list(hook)) {
            hook$code <- sprintf(hookWrapperTemplate, paste(hook$code, collapse = "\n"))
          } else if (is.character(hook)) {
            hook <- sprintf(hookWrapperTemplate, paste(hook, collapse = "\n"))
          } else {
            stop("Unknown hook class ", class(hook))
          }
          hook
        })
      }
      widget
    }
  )

  if (crosstalk::is.SharedData(data)) {
    map <- addSelect(map)
  }

  map
}

hookWrapperTemplate <- "function(el, x, data) {
  return (%s).call(this.getMap(), el, x, data);
}"

#' returns the map's data
#' @param map the map
#' @export
getMapData <- function(map) {
  attr(map$x, "leafletData", exact = TRUE)
}

#' Set options on a leaflet map object
#'
#' @param map A map widget object created from \code{\link{leaflet}()}
#' @param zoomToLimits Controls whether the map is zooms to the limits of the
#'   elements on the map. This is useful for interactive applications where the
#'   map data is updated. If \code{"always"} (the default), the map always
#'   re-zooms when new data is received; if \code{"first"}, it zooms to the
#'   elements on the first rendering, but does not re-zoom for subsequent data;
#'   if \code{"never"}, it never re-zooms, not even for the first rendering.
#'
#' @examples
#' # Don't auto-zoom to the objects (can be useful in interactive applications)
#' leaflet() %>%
#'   addTiles() %>%
#'   addPopups(174.7690922, -36.8523071, 'R was born here!') %>%
#'   mapOptions(zoomToLimits = "first")
#' @export
mapOptions <- function(map, zoomToLimits = c("always", "first", "never")) {
  if (is.null(map$x$options))
    map$x$options <- list()

  zoomToLimits <- match.arg(zoomToLimits)
  map$x$options$zoomToLimits <- zoomToLimits

  map
}

#' Options for Map creation
#' @param  minZoom Minimum zoom level of the map. Overrides any minZoom set on map layers.
#' @param  maxZoom Maximum zoom level of the map. This overrides any maxZoom set on map layers.
#' @param  crs Coordinate Reference System to use. Don't change this if you're not sure what it means.
#' @seealso \code{\link{leafletCRS}} for creating a custom CRS.
#' @param  worldCopyJump With this option enabled, the map tracks when you pan to another "copy" of the world and seamlessly jumps to the original one so that all overlays like markers and vector layers are still visible.
#' @param ... other options.
#' @describeIn leaflet Options for map creation
#' @seealso \url{http://leafletjs.com/reference.html#map-options} for details.
#' @export
leafletOptions <- function(
  minZoom = NULL,
  maxZoom = NULL,
  crs = leafletCRS(),
  worldCopyJump = NULL,
  ...) {
  filterNULL(
    list(
      minZoom = minZoom,
      maxZoom = maxZoom,
      crs = crs,
      worldCopyJump = worldCopyJump,
      ...)
  )
}

# CRS classes supported
crsClasses <- list('L.CRS.EPSG3857', 'L.CRS.EPSG4326', 'L.CRS.EPSG3395',
                   'L.CRS.Simple', 'L.Proj.CRS', 'L.Proj.CRS.TMS')

#' creates a custom CRS
#' Refer to \url{https://kartena.github.io/Proj4Leaflet/api/} for details.
#' @param crsClass One of L.CRS.EPSG3857, L.CRS.EPSG4326, L.CRS.EPSG3395,
#' L.CRS.Simple, L.Proj.CRS, L.Proj.CRS.TMS
#' @param code CRS identifier
#' @param proj4def Proj4 string
#' @param projectedBounds Only when crsClass = 'L.Proj.CRS.TMS'
#' @param origin Origin in projected coordinates, if set overrides transformation option.
#' @param transformation to use when transforming projected coordinates into pixel coordinates
#' @param scales Scale factors (pixels per projection unit, for example pixels/meter)
#'   for zoom levels; specify either scales or resolutions, not both
#' @param resolutions factors (projection units per pixel, for example meters/pixel)
#'   for zoom levels; specify either scales or resolutions, not both
#' @param bounds Bounds of the CRS, in projected coordinates; if defined,
#'    Proj4Leaflet will use this in the getSize method, otherwise
#'    defaulting to Leaflet's default CRS size
#' @param tileSize Tile size, in pixels, to use in this CRS (Default 256)
#'    Only needed when crsClass = 'L.Proj.CRS.TMS'
#' @describeIn leaflet class to create a custom CRS
#' @export
leafletCRS <- function(
  crsClass = 'L.CRS.EPSG3857',
  code = NULL,
  proj4def = NULL,
  projectedBounds = NULL,
  origin = NULL,
  transformation = NULL,
  scales = NULL,
  resolutions = NULL,
  bounds = NULL,
  tileSize = NULL
) {
  if(!crsClass %in% crsClasses) {
    stop(sprintf("crsClass argument must be one of %s",
                 paste0(crsClasses, collapse = ', ')))

  }
  if(crsClass %in% c('L.Proj.CRS', 'L.Proj.CRS.TMS') &&
    !is.null(scales) && !is.null(resolutions)) {
    stop(sprintf("Either input scales or resolutions"))
  }
  if(crsClass %in% c('L.Proj.CRS', 'L.Proj.CRS.TMS') &&
    is.null(scales) && is.null(resolutions)) {
    stop(sprintf("Input either scales or resolutions, not both"))
  }
    structure(
      list(
        crsClass = crsClass,
        code = code,
        proj4def = proj4def,
        projectedBounds = projectedBounds,
        options = filterNULL(list(
          origin = origin,
          transformation = transformation,
          scales = scales,
          resolutions = resolutions,
          bounds = bounds,
          tileSize = tileSize
        ))
      ),
      class = 'leaflet_crs'
  )
}

