leafletAwesomeMarkersDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-awesomemarkers",
      "2.0.2",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      script = c('leaflet-awesome-markers.js','bootstrap/js/bootstrap.min.js'),
      stylesheet = c('leaflet-awesome-markers.css','bootstrap/css/bootstrap.min.css',
                     'font-awesome/css/font-awesome.min.css','ionicon/css/ionicon.min.css')
    )
  )
}

#' Creates a Marker with awesome-marker icons
#'
#' @param map a map widget object
#' see \url{https://github.com/lvoogdt/Leaflet.awesome-markers}
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addAwesomeMarkers()
#'
#' @export
addAwesomeMarkers <- function(
  map
) {
  map$dependencies <- c(map$dependencies, leafletAwesomeMarkersDependencies())
  map
}
#' Creates a Marker with awesome-marker icons
#'
#' @param
#' icon,prefix,markerColor,iconColor,spin,extraClasses
#' see \url{https://github.com/lvoogdt/Leaflet.awesome-markers}
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @examples
#' library(leaflet)
#'
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addAwesomeMarkers()
#'
#' @export
createAwesomeMarkerIcon <- function(
  icon = 'home',
  prefix = 'glyphicon',
  markerColor = 'blue',
  iconColor = 'white',
  spin = FALSE,
  extraClasses = ''
) {
  JS(
   'L.AwesomeMarkers.icon({'
	, 'icon: \'' , icon , '\', '
	, 'prefix: \'' , prefix , '\', '
	, 'markerColor: \'' , markerColor , '\', '
	, 'iconColor: \'' , iconColor , '\', '
	, 'spin: \'' , spin , '\', '
	, 'prefix: \'' , prefix , '\''
	,'});'
  )
}
