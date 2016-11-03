#' Various leaflet dependency functions for use in downstream packages
#' @examples \dontrun{
#' addBootStrap <- function(map) {
#'   map$dependencies <- c(map$dependencies, leafletDependencies$bootstrap())
#'   map
#' }
#' }
#' @export
leafletDependencies <- list(
  markerCluster = function() {markerClusterDependencies()},
  awesomeMarkers = function(){leafletAwesomeMarkersDependencies()},
  bootstrap = function(){leafletAmBootstrapDependencies()},
  fontawesome = function(){leafletAmFontAwesomeDependencies()},
  ionicon = function(){leafletAmIonIconDependencies()},
  omnivore = function(){leafletOmnivoreDependencies()},
  # the ones below are not really expected to be used directly
  # but are included for completeness sake.
  graticule = function(){leafletGraticuleDependencies()},
  simpleGraticule = function(){leafletSimpleGraticuleDependencies()},
  easyButton = function(){leafletEasyButtonDependencies()},
  measure = function(){leafletMeasureDependencies()},
  terminator = function(){leafletTerminatorDependencies()},
  minimap = function(){leafletMiniMapDependencies()},
  providers = function(){leafletProviderDependencies()}
)
