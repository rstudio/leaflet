leafletProviderDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-providers",
      "1.0.27",
      system.file("htmlwidgets/lib/leaflet-providers", package = "leaflet"),
      script = "leaflet-providers.js"
    ),
    htmltools::htmlDependency(
      "leaflet-providers-plugin",
      packageVersion("leaflet"),
      system.file("htmlwidgets/plugins/leaflet-providers-plugin", package = "leaflet"),
      script = "leaflet-providers-plugin.js"
    )
  )
}

#' Add a tile layer from a known map provider
#'
#' @param map the map to add the tile layer to
#' @param provider the name of the provider (see
#'   \url{http://leaflet-extras.github.io/leaflet-providers/preview/} and
#'   \url{https://github.com/leaflet-extras/leaflet-providers})
#' @param layerId the layer id to assign
#' @param options tile options
#' @return modified map object
#'
#' @examples
#' \donttest{
#' leaflet() %>%
#'   addProviderTiles("Stamen.Watercolor") %>%
#'   addProviderTiles("Stamen.TonerHybrid")
#' }
#'
#' @export
addProviderTiles <- function(
  map,
  provider,
  layerId = NULL,
  options = providerTileOptions()
) {
  map$dependencies <- c(map$dependencies, leafletProviderDependencies())
  invokeMethod(map, getMapData(map), 'addProviderTiles',
    provider, layerId, options)
}

#' @param opacity the opacity of the layer (or \code{NULL} for the provider
#'   default)
#' @param ... named parameters to add to the options
#' @rdname addProviderTiles
#' @export
providerTileOptions <- function(opacity = NULL, ...) {
  list(opacity = opacity, ...)
}
