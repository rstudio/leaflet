leafletProviderDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-providers",
      "1.1.17",
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
#' @param group the name of the group the newly created layers should belong to
#'   (for \code{\link{clearGroup}} and \code{\link{addLayersControl}} purposes).
#'   Human-friendly group names are permitted--they need not be short,
#'   identifier-style names.
#' @param options tile options
#' @return modified map object
#'
#' @examples
#' leaflet() %>%
#'   addProviderTiles("Stamen.Watercolor") %>%
#'   addProviderTiles("Stamen.TonerHybrid")
#'
#' @export
addProviderTiles <- function(
  map,
  provider,
  layerId = NULL,
  group = NULL,
  options = providerTileOptions()
) {
  map$dependencies <- c(map$dependencies, leafletProviderDependencies())
  invokeMethod(map, getMapData(map), "addProviderTiles",
    provider, layerId, group, options)
}

#' @param
#' errorTileUrl,noWrap,opacity,zIndex,updateWhenIdle,detectRetina
#' the tile layer options; see
#' \url{http://leafletjs.com/reference-1.3.1.html#tilelayer}
#' @param ... named parameters to add to the options
#' @rdname addProviderTiles
#' @export
providerTileOptions <- function(errorTileUrl = "", noWrap = FALSE,
  opacity = NULL, zIndex = NULL,
  updateWhenIdle = NULL, detectRetina = FALSE, ...
) {
  opts <- filterNULL(list(
    errorTileUrl = errorTileUrl, noWrap = noWrap,
    opacity = opacity,  zIndex = zIndex,
    updateWhenIdle = updateWhenIdle, detectRetina = detectRetina,
    ...))
  opts
}

#' Providers
#'
#' List of all providers with their variations
#'
#' @format A list of characters
#' @source \url{https://github.com/leaflet-extras/leaflet-providers/blob/master/leaflet-providers.js}
"providers"

#' Providers Details
#'
#' List of all providers with their variations and additional info
#'
#' @format A list of lists (JSON)
#' @source \url{https://github.com/leaflet-extras/leaflet-providers/blob/master/leaflet-providers.js}
"providers.details"
