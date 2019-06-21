leafletProviderDependencies <- function() {
  list(
    get_providers_html_dependency(),
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
#'
#' @export
#' @rdname providers
providers <- NULL
get_providers <- function() {
  get_leaflet_providers_options("leaflet_providers", default = providers)
}

#' @export
#' @rdname providers
providers.details <- NULL
get_providers_details <- function() {
  get_leaflet_providers_options("providers_details", default = providers.details)
}

providers.version_num <- NULL

get_providers_version_num <- function() {
  get_leaflet_providers_options("version_num", default = providers.version_num)
}

providers.src <- NULL

get_providers_html_dependency <- function() {
  tmpfile <- file.path(tempdir(), paste0("leaflet-providers_", get_providers_version_num(), ".js"))

  if (!file.exists(tmpfile)) {
    src <- get_leaflet_providers_options("src", default = providers.src)
    writeLines(src, tmpfile)
  }

  html_dependency <- htmltools::htmlDependency(
    "leaflet-providers",
    get_providers_version_num(),
    src = tmpfile
  )
}

get_leaflet_providers_options <- function(key, default) {
  info <- getOption("leaflet.providers")
  if (!is.null(info)) {
    val <- info[[key]]
    if (!is.null(val)) {
      return(val)
    }
  }
  return(default)
}
