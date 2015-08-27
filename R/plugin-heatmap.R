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
#' @return modified map
#'
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
