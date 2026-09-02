leafletProviderDependencies <- function() {
  list(
    get_providers_html_dependency(),
    htmltools::htmlDependency(
      "leaflet-providers-plugin",
      get_package_version("leaflet"),
      "htmlwidgets/plugins/leaflet-providers-plugin",
      package = "leaflet",
      script = "leaflet-providers-plugin.js"
    )
  )
}

# Returns TRUE if the named provider uses vector tiles (type: 'vector' in the
# provider definition). Reads the type field from providers.details, which is
# populated by leaflet.providers when it parses leaflet-providers.js.
is_vector_provider <- function(provider) {
  provider_name <- strsplit(provider, "\\.")[[1]][1]
  details <- tryCatch(
    leaflet.providers::providers_loaded()$providers_details,
    error = function(e) NULL
  )
  if (!is.null(details) && provider_name %in% names(details)) {
    isTRUE(details[[provider_name]]$type == "vector")
  } else {
    FALSE
  }
}

# HTML dependencies for maplibre-gl and its Leaflet adapter, required when
# rendering vector tile providers. Loaded from the unpkg CDN.
maplibreGLDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "maplibre-gl",
      "5.0.0",
      src = c(href = "https://unpkg.com/maplibre-gl@5/dist"),
      script = "maplibre-gl.js",
      stylesheet = "maplibre-gl.css"
    ),
    htmltools::htmlDependency(
      "maplibre-gl-leaflet",
      "0.0.20",
      src = c(href = "https://unpkg.com/@maplibre/maplibre-gl-leaflet"),
      script = "leaflet-maplibre-gl.js"
    )
  )
}

#' Add a tile layer from a known map provider
#'
#' @param map the map to add the tile layer to
#' @param provider the name of the provider (see
#'   <https://leaflet-extras.github.io/leaflet-providers/preview/> and
#'   <https://github.com/leaflet-extras/leaflet-providers>)
#' @param layerId the layer id to assign
#' @param group the name of the group the newly created layers should belong to
#'   (for [clearGroup()] and [addLayersControl()] purposes). Human-friendly
#'   group names are permitted--they need not be short, identifier-style names.
#' @param options tile options
#' @param check Check that the specified `provider` matches the available
#'   currently loaded leaflet providers? Defaults to `TRUE`, but can be toggled
#'   to `FALSE` for advanced users.
#' @return modified map object
#'
#' @details
#' Providers that use vector tiles (e.g. `OpenFreeMap`) require
#' [maplibre-gl](https://maplibre.org/maplibre-gl-js/) and
#' [maplibre-gl-leaflet](https://github.com/maplibre/maplibre-gl-leaflet).
#' These are loaded automatically from the unpkg CDN when a vector provider is
#' detected. No extra setup is required.
#'
#' @examples
#' leaflet() %>%
#'   addProviderTiles("Esri.WorldTopoMap") %>%
#'   addProviderTiles("CartoDB.DarkMatter")
#'
#' # Vector tile provider (requires maplibre-gl, loaded automatically)
#' leaflet() %>%
#'   addProviderTiles("OpenFreeMap.Liberty")
#'
#' @export
addProviderTiles <- function(
  map,
  provider,
  layerId = NULL,
  group = NULL,
  options = providerTileOptions(),
  check = TRUE
) {
  if (check) {
    loaded_providers <- leaflet.providers::providers_loaded()
    if (!provider %in% names(loaded_providers$providers)) {
      stop(
        "Unknown tile provider '",
        provider,
        "'; either use a known provider or pass `check = FALSE` to `addProviderTiles()`"
      )
    }
  }
  deps <- leafletProviderDependencies()
  if (is_vector_provider(provider)) {
    deps <- c(deps, maplibreGLDependencies())
  }
  map$dependencies <- c(map$dependencies, deps)
  invokeMethod(map, getMapData(map), "addProviderTiles",
    provider, layerId, group, options)
}

#' @param
#' errorTileUrl,noWrap,opacity,zIndex,updateWhenIdle,detectRetina
#' the tile layer options; see
#' <https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#tilelayer>
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
#' @source <https://github.com/leaflet-extras/leaflet-providers/blob/0a9e27f8c6c26956b4e78c26e1945d748e3c2869/leaflet-providers.js>
#'
#' @name providers
#' @export providers
#' @examples
#' providers
NULL
# Active binding added in zzz.R
"providers"

#' @name providers.details
#' @export providers.details
#' @rdname providers
NULL
# Active binding added in zzz.R
"providers.details"

# Active binding added in zzz.R
"providers.version_num"

# Active binding added in zzz.R
"providers.src"

# Active binding added in zzz.R
"providers.dep"

get_providers_html_dependency <- function() {
  if (is.null(providers.dep)) {
    return(create_temp_providers_html_dependency())
  }

  providers.dep
}

create_temp_providers_html_dependency <- function() {
  # for compatibility with older versions of leaflet.providers
  tmpfile <- file.path(tempdir(), paste0("leaflet-providers_", providers.version_num, ".js"))

  if (!file.exists(tmpfile)) {
    src <- providers.src
    writeLines(src, tmpfile)
  }

  htmltools::htmlDependency(
    "leaflet-providers",
    providers.version_num,
    src = dirname(tmpfile),
    script = basename(tmpfile),
    all_files = FALSE
  )
}
