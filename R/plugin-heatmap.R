leafletHeatmapDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-heat",
      "0.1.3",
      system.file("htmlwidgets/lib/leaflet-heat", package = "leaflet"),
      script = "leaflet-heat.js"
    )
  )
}

#' Add a heatmap to the map.
#'
#' @param map leaflet map to which you would like to add the heatmap
#' @param data the data object from which the argument values are derived; by default,
#'          it is the data object provided to leaflet() initially,
#'          but can be overridden
#' @param lng	a numeric vector of longitudes, or a one-sided formula
#'           of the form ~x where x is a variable in data;
#'           by default (if not explicitly provided), it will be
#'           automatically inferred from data by looking for a
#'           column named lng, long, or longitude (case-insensitively)
#' @param lat	a vector of latitudes or a formula
#'            (similar to the lng argument; the names lat and
#'            latitude are used when guessing the latitude column
#'            from data)
#' @param minOpacity minimum opacity at which the heat will start
#' @param maxZoom zoom level where the points reach maximum intensity
#'          (as intensity scales with zoom)
#' @param max maximum point intensity. The default is \code{1.0}
#' @param radius radius of each "point" of the heatmap.  The default is
#'          \code{25}.
#' @param blur amount of blur to apply.  The default is \code{15}.
#'          \code{blur=1} means no blur.
#' @param gradient palette name from \code{RColorBrewer} or an array of
#'          of colors to be provided to \link{\code{colorNumeric}}
#' @param layerId optional string identifying this layer.  \code{layerId} can
#'          be helpful in a dynamic/Shiny situation where you might want to
#'          remove at some point
#'
#' @return modified map
#'
#' @example ./inst/examples/heatmap.R
#'
#' @export

addHeatmap <- function( map, lng = NULL, lat = NULL,
                        minOpacity = 0.05, intensity = NULL,
                        maxZoom = NULL, max = 1.0, radius = 25,
                        blur = 15, gradient = NULL, layerId = NULL,
                        data = getMapData(map)) {
  map$dependencies <- c(map$dependencies, leafletHeatmapDependencies())

  #convert gradient to expected format from leaflet
  if(!is.null(gradient)){
    gradient <- colorNumeric( gradient, 0:1 )
    gradient <- as.list(gradient(0:20 / 20))
    names(gradient) <- as.character(0:20 / 20)
  }

  # using code from addMarkers to get points to supply
  pts = derivePoints(data, lng, lat, missing(lng), missing(lat),
                     "addHeatmap")

  # get intensity if provided
  if(!is.null(intensity)){
    intensity <- resolveFormula( intensity, data )
  }

  invokeMethod(
    map, data, 'addHeatmap', pts$lat, pts$lng, intensity,
    Filter(
      Negate(is.null),
      list(
        minOpacity = minOpacity,
        maxZoom = maxZoom,
        max = max,
        radius = radius,
        blur = blur,
        gradient = gradient
    )),
    layerId
  ) %>%
    expandLimits(pts$lat,pts$lng)
}

#' @export
#' @rdname remove
removeHeatmap <- function( map, layerId = NULL ){
  invokeMethod(
    map
    , getMapData(map)
    , 'removeHeatmap'
    , layerId
  )
}

#' @rdname remove
#' @export
clearHeatmap = function(map) {
  invokeMethod(map, NULL, 'clearHeatmap')
}
