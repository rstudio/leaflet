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
#' @param map leaflet map to which you would like to add the heatmap.
#' @param latlngs matrix of data with latitude in the first column
#'          and longitude in the second.  An optional third column
#'          can provide altitude or intensity.
#' @param minOpacity minimum opacity at which the heat will start.
#' @param maxZoom zoom level where the points reach maximum intensity
#'          (as intensity scales with zoom).
#' @param max maximum point intensity. The default is \code{1.0}.
#' @param radius radius of each "point" of the heatmap.  The default is
#'          \code{25}.
#' @param blur amount of blur to apply.  The default is \code{15}.
#'          \code{blur=1} means no blur.
#' @param gradient manual color gradient.  An example is
#'          \code{gradient = list( '0.4' = 'blue', '0.65' = 'lime', '1'= 'red')}.
#' @param layerId optional string identifying this layer.  \code{layerId} can
#'          be helpful in a dynamic/Shiny situation where you might want to
#'          remove at some point.
#'
#' @return modified map
#'
#' @example ./inst/examples/heatmap.R
#'
#' @export

addHeatmap <- function(
  map
  ,latlngs
  ,minOpacity = 0.05 #- the minimum opacity the heat will start at
  ,maxZoom = NULL #- zoom level where the points reach maximum intensity (as intensity scales with zoom), equals maxZoom of the map by default
  ,max = 1.0 #- maximum point intensity, 1.0 by default
  ,radius = 25 #- radius of each "point" of the heatmap, 25 by default
  ,blur = 15 #- amount of blur, 15 by default
  ,gradient = NULL
  ,layerId = NULL
) {
  map$dependencies <- c(map$dependencies, leafletHeatmapDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addHeatmap'
    , latlngs
    , Filter(
        Negate(is.null)
        ,list(
          minOpacity = minOpacity
          ,maxZoom = maxZoom
          ,max = max
          ,radius = radius
          ,blur = blur
          ,gradient = gradient
      ))
    , layerId
  )
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
