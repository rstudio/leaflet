leafletGraticuleDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-graticule",
      "0.1.0",
      "htmlwidgets/plugins/Leaflet.Graticule",
      package = "leaflet",
      script = c("L.Graticule.js", "Graticule-binding.js")
    )
  )
}

#' Add a Graticule on the map
#' see \url{https://github.com/turban/Leaflet.Graticule}
#'
#' @param map a map widget object
#' @param interval The spacing in map units between horizontal and vertical lines.
#' @param sphere boolean. Default FALSE
#' @param style path options for the generated lines. See \url{https://web.archive.org/web/20220702182250/https://leafletjs.com/reference-1.3.4.html#path-option}
#' @param layerId the layer id
#' @param group the name of the group this layer belongs to.
#' @param options the path options for the graticule layer
#' @examples
#' leaf <- leaflet() %>%
#'   addTiles() %>%
#'   addGraticule()
#' leaf
#'
#' @export
addGraticule <- function(
  map,
  interval = 20,
  sphere = FALSE,
  style = list(color = "#333", weight = 1),
  layerId = NULL,
  group = NULL,
  options = pathOptions(pointerEvents = "none", clickable = FALSE) # Default unclickable
) {
  map$dependencies <- c(map$dependencies, leafletGraticuleDependencies())
  invokeMethod(
    map,
    getMapData(map),
    "addGraticule",
    interval,
    sphere,
    style,
    layerId,
    group,
    options
  )
}
