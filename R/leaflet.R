#' Leaflet sizing policy
#'
#' Sizing policy used withing leaflet htmlwidgets.
#'
#' @export
#' @param defaultWidth defaults to `"100%"` of the available width
#' @param defaultHeight defaults to 400px tall
#' @param padding defaults to 0px
#' @param browser.fill defaults to `TRUE`
#' @inheritDotParams htmlwidgets::sizingPolicy
#' @return An `htmlwidgets::sizingPolicy` object
leafletSizingPolicy <- function(
  defaultWidth = "100%",
  defaultHeight = 400,
  padding = 0,
  browser.fill = TRUE,
  ...
  # not adding extra arguments as htmlwidgets::sizingPolicy can change their own args
) {
  htmlwidgets::sizingPolicy(
    defaultWidth = defaultWidth,
    defaultHeight = defaultHeight,
    padding = padding,
    browser.fill = browser.fill,
    ...
  )
}


#' Create a Leaflet map widget
#'
#' @description
#' * `leaflet()` creates a Leaflet map widget using \pkg{htmlwidgets}. The
#' widget can be rendered on HTML pages generated from R Markdown, Shiny, or
#' other applications.
#' * `leafletOptions()`: options for map creation
#' * `leafletCRS()`: class to create custom CRS.
#'
#' @details
#' The `data` argument is only needed if you are going to reference
#' variables in this object later in map layers. For example, `data` can be
#' a data frame containing columns `latitude` and `longitude`, then
#' we may add a circle layer to the map by
#' `leaflet(data) %>% addCircles(lat = ~latitude, lng = ~longitude)`,
#' where the variables in the formulae will be evaluated in the `data`.
#' @param data a data object. Currently supported objects are matrix, data
#' frame, spatial data from the \pkg{sf} package,
#' `SpatVector` from the \pkg{terra} package
#'
#' \pkg{sp} object are normalized to \pkg{sf} objects with [sf::st_as_sf()].
#' Conversion may fail for `sp::Polygons`, `sp::Lines`, `sp::Polygon` etc.
#' You are encouraged to use the appropriate function to create them. `sf::st_polygon()` for example.
#'
#' @param width the width of the map
#' @param height the height of the map
#' @param padding the padding of the map
#' @param options the map options
#' @param elementId Use an explicit element ID for the widget
#'   (rather than an automatically generated one).
#' @param sizingPolicy htmlwidgets sizing policy object. Defaults to [leafletSizingPolicy()]
#' @return A HTML widget object, on which we can add graphics layers using
#'   `%>%` (see examples).
#' @example inst/examples/leaflet.R
#' @export
leaflet <- function(data = NULL, width = NULL, height = NULL,
                   padding = 0, options = leafletOptions(),
                   elementId = NULL, sizingPolicy = leafletSizingPolicy(padding = padding)) {
  # Validate the CRS if specified
  if (!is.null(options[["crs"]]) &&
      !inherits(options[["crs"]], "leaflet_crs")) {
    stop("CRS in mapOptions should be a return value of leafletCRS() function")
  }

  # If is legacy sp object, transform to sf.
  is_sp <- tryCatch(identical(attr(class(data), "package"), "sp"), error = function(e) FALSE)
  if (is_sp) {
    rlang::check_installed("sp")
    # transform object to sf if possible
    data <- maybe_as_sf(data)
  }

  map <- htmlwidgets::createWidget(
    "leaflet",
    structure(
      list(options = options),
      leafletData = data
    ),
    width = width, height = height,
    sizingPolicy = sizingPolicy,
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
    },
    elementId = elementId,
    dependencies = leafletBindingDependencies()
  )

  if (crosstalk::is.SharedData(data)) {
    map <- addSelect(map)
  }

  map
}

hookWrapperTemplate <- "function(el, x, data) {
  return (%s).call(this.getMap(), el, x, data);
}"

#' Extract the map's data
#' @param map the map
#' @returns The map's data
#' @export
getMapData <- function(map) {
  attr(map$x, "leafletData", exact = TRUE)
}

#' Set options on a leaflet map object
#'
#' @param map A map widget object created from [leaflet()]
#' @param zoomToLimits Controls whether the map is zooms to the limits of the
#'   elements on the map. This is useful for interactive applications where the
#'   map data is updated. If `"always"` (the default), the map always
#'   re-zooms when new data is received; if `"first"`, it zooms to the
#'   elements on the first rendering, but does not re-zoom for subsequent data;
#'   if `"never"`, it never re-zooms, not even for the first rendering.
#'
#' @examples
#' # Don't auto-zoom to the objects (can be useful in interactive applications)
#' leaflet() %>%
#'   addTiles() %>%
#'   addPopups(174.7690922, -36.8523071, "R was born here!") %>%
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
#' @param  minZoom Minimum zoom level of the map. Overrides any `minZoom` set on map layers.
#' @param  maxZoom Maximum zoom level of the map. This overrides any `maxZoom` set on map layers.
#' @param  crs Coordinate Reference System to use. Don't change this if you're not sure what it means.
#' @param  worldCopyJump With this option enabled, the map tracks when you pan
#'   to another "copy" of the world and seamlessly jumps to the original
#'   one so that all overlays like markers and vector layers are still visible.
#' @param preferCanvas Whether leaflet.js Paths should be rendered on a Canvas renderer.
#' @param ... other options used for leaflet.js map creation.
#' @rdname leaflet
#' @seealso See <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#map-option> for details and more options.
#' @export
leafletOptions <- function(
  minZoom = NULL,
  maxZoom = NULL,
  crs = leafletCRS(),
  worldCopyJump = NULL,
  preferCanvas = NULL,
  ...) {
  filterNULL(
    list(
      minZoom = minZoom,
      maxZoom = maxZoom,
      crs = crs,
      worldCopyJump = worldCopyJump,
      preferCanvas = preferCanvas,
      ...)
  )
}

# CRS classes supported
crsClasses <- list("L.CRS.EPSG3857", "L.CRS.EPSG4326", "L.CRS.EPSG3395",
                   "L.CRS.Simple", "L.Proj.CRS", "L.Proj.CRS.TMS")

#' creates a custom CRS
#' Refer to <https://kartena.github.io/Proj4Leaflet/api/> for details.
#' @param crsClass One of L.CRS.EPSG3857, L.CRS.EPSG4326, L.CRS.EPSG3395,
#' L.CRS.Simple, L.Proj.CRS
#' @param code CRS identifier
#' @param proj4def Proj4 string
#' @param projectedBounds DEPRECATED! Use the bounds argument.
#' @param origin Origin in projected coordinates, if set overrides transformation option.
#' @param transformation to use when transforming projected coordinates into pixel coordinates
#' @param scales Scale factors (pixels per projection unit, for example pixels/meter)
#'   for zoom levels; specify either scales or resolutions, not both
#' @param resolutions factors (projection units per pixel, for example meters/pixel)
#'   for zoom levels; specify either scales or resolutions, not both
#' @param bounds Bounds of the CRS, in projected coordinates; if defined,
#'    Proj4Leaflet will use this in the getSize method, otherwise
#'    defaulting to Leaflet's default CRS size
#' @param tileSize DEPRECATED! Specify the tilesize in the [tileOptions()] argument.
#' @rdname leaflet
#' @export
leafletCRS <- function(
  crsClass = "L.CRS.EPSG3857",
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

  # Deprecated since Leaflet JS 1.x
 if (!missing(projectedBounds)) {
    warning("projectedBounds argument is deprecated and has no effect, use the bounds argument.")
  }
 if (!missing(tileSize)) {
    warning("tileSize argument is deprecated and has no effect, use the tileOptions() function to pass the tileSize argument to the addTiles() function") # nolint
  }
 if (crsClass == "L.Proj.CRS.TMS") {
    warning("L.Proj.CRS.TMS is deprecated and will behave exactly like L.Proj.CRS.")
  }

 if (!crsClass %in% crsClasses) {
    stop(sprintf("crsClass argument must be one of %s",
                 paste0(crsClasses, collapse = ", ")))
  }



 if (crsClass %in% c("L.Proj.CRS", "L.Proj.CRS.TMS") &&
    !is.null(scales) && !is.null(resolutions)) {
    stop(sprintf("Either specify scales or resolutions"))
  }
 if (crsClass %in% c("L.Proj.CRS", "L.Proj.CRS.TMS") &&
    is.null(scales) && is.null(resolutions)) {
    stop(sprintf("Specify either scales or resolutions, not both"))
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
      class = "leaflet_crs"
  )
}
