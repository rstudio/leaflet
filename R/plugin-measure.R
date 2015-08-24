leafletMeasureDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-measure",
      "1.2.0",
      system.file("htmlwidgets/lib/leaflet-measure", package = "leaflet"),
      script = "leaflet-measure.min.js",
      stylesheet = "leaflet-measure.css"
    )
  )
}

#' Add a measure control to the map.
#'
#' @param measureOptions \code{list} of options as described in \href{https://github.com/ljagis/leaflet-measure#control-options}{leaflet-measure}.
#' @return modified map
#' @examples
#' leaflet() %>%
#'   addMeasure()
#' @export
addMeasure <- function( map, measureOptions=NULL ) {
  map$dependencies <- c(map$dependencies, leafletMeasureDependencies())
  invokeMethod(
    map
    , getMapData(map)
    , 'addMeasure'
    , measureOptions
  )
}

#' @export
#' @rdname remove
removeMeasure <- function( map ){
  invokeMethod(
    map
    , getMapData(map)
    , 'removeMeasure'
  )
}
