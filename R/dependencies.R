# N.B. These are all the dependencies required to define leaflet's htmlwidget
# binding. We've intentionally avoided htmlwidgets' yaml approach to defining
# these since jQuery (in particular) wants to be defined with R code and must be
# provided first. For static rendering, it's sufficient to provide these to
# htmlwidgets::createWidget(dependencies = ...); however, when we dynamically
# render (via renderLeaflet()) the output container (i.e., leafletOutput()) also
# needs these dependencies attached (without them, the output binding won't be
# registered in the time when shiny binds to the DOM). Typically, we don't need
# to do this since htmlwidgets will automatically attach dependencies defined in
# yaml to the output container (which we cannot do anymore).
leafletBindingDependencies <- function() {
  list(
    jquerylib::jquery_core(3),
    htmltools::htmlDependency(
      name = "leaflet",
      version = "1.3.1",
      package = "leaflet",
      src = "htmlwidgets/lib/leaflet",
      script = "leaflet.js",
      stylesheet = "leaflet.css"
    ),
    htmltools::htmlDependency(
      name = "leafletfix",
      version = "1.0.0",
      package = "leaflet",
      src = "htmlwidgets/lib/leafletfix",
      stylesheet = "leafletfix.css"
    ),
    htmltools::htmlDependency(
      name = "proj4",
      version = "2.6.2",
      package = "leaflet",
      src = "htmlwidgets/plugins/Proj4Leaflet",
      script = "proj4.min.js",
      all_files = FALSE
    ),
    htmltools::htmlDependency(
      name = "Proj4Leaflet",
      version = "1.0.1",
      package = "leaflet",
      src = "htmlwidgets/plugins/Proj4Leaflet",
      script = "proj4leaflet.js",
      all_files = FALSE
    ),
    htmltools::htmlDependency(
      name = "rstudio_leaflet",
      version = "1.3.1",
      package = "leaflet",
      src = "htmlwidgets/lib/rstudio_leaflet",
      stylesheet = "rstudio_leaflet.css"
    ),
    # Include the rstudio leaflet binding last
    # https://github.com/ramnathv/htmlwidgets/blob/7b9c1ea3d9fbf4736d84f1fd1178fce0af29f8e3/R/utils.R#L59-L68
    htmltools::htmlDependency(
      name = "leaflet-binding",
      version = get_package_version("leaflet"),
      src = "htmlwidgets/assets",
      package = "leaflet",
      script = "leaflet.js",
      all_files = FALSE
    )
  )
}


#' Various leaflet dependency functions for use in downstream packages
#' @examples \dontrun{
#' addBootStrap <- function(map) {
#'   map$dependencies <- c(map$dependencies, leafletDependencies$bootstrap())
#'   map
#' }
#' }
#' @export
leafletDependencies <- list(
  markerCluster = function() {
    markerClusterDependencies()
  },
  awesomeMarkers = function() {
    leafletAwesomeMarkersDependencies()
  },
  bootstrap = function() {
    leafletAmBootstrapDependencies()
  },
  fontawesome = function() {
    leafletAmFontAwesomeDependencies()
  },
  ionicon = function() {
    leafletAmIonIconDependencies()
  },
  omnivore = function() {
    leafletOmnivoreDependencies()
  },

  # the ones below are not really expected to be used directly
  # but are included for completeness sake.
  graticule = function() {
    leafletGraticuleDependencies()
  },
  simpleGraticule = function() {
    leafletSimpleGraticuleDependencies()
  },
  easyButton = function() {
    leafletEasyButtonDependencies()
  },
  measure = function() {
    leafletMeasureDependencies()
  },
  terminator = function() {
    leafletTerminatorDependencies()
  },
  minimap = function() {
    leafletMiniMapDependencies()
  },
  providers = function() {
    leafletProviderDependencies()
  }
)
