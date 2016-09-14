leafletProj4LeafletDependencies <- function() {
    list(
         htmltools::htmlDependency(
                                   "proj4leaflet",
                                   "0.7.2",
                                   system.file("htmlwidgets/plugins/Proj4Leaflet", package = "leaflet"),
                                   script = c('proj4-compressed.js', 'proj4leaflet.js')
                                   )
         )
}

#' Adds support for Proj4Leaflet
#' @param map The Leaflet map.
#' @export
addProj4Leaflet <- function(map) {
  map$dependencies <- c(map$dependencies, leafletProj4LeafletDependencies())
  map
}

