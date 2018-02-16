leafletOmnivoreDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-omnivore",
      "0.3.3",
      system.file("htmlwidgets/lib/leaflet-omnivore", package = "leaflet"),
      script = "leaflet-omnivore.min.js"
    )
  )
}


#' @param topojson a TopoJSON list, or character vector of length 1
#' @describeIn map-layers Add TopoJSON layers to the map
#' @export
addTopoJSON <- function(map, topojson, layerId = NULL, group = NULL,
  stroke = TRUE,
  color = "#03F",
  weight = 5,
  opacity = 0.5,
  fill = TRUE,
  fillColor = color,
  fillOpacity = 0.2,
  dashArray = NULL,
  smoothFactor = 1.0,
  noClip = FALSE,
  options = pathOptions()
) {
  map$dependencies <- c(map$dependencies, leafletOmnivoreDependencies())
  options <- c(options, list(
    stroke = stroke, color = color, weight = weight, opacity = opacity,
    fill = fill, fillColor = fillColor, fillOpacity = fillOpacity,
    dashArray = dashArray, smoothFactor = smoothFactor, noClip = noClip
  ))
  invokeMethod(map, getMapData(map), "addTopoJSON", topojson, layerId, group, options)
}

#' @rdname remove
#' @export
removeTopoJSON <- function(map, layerId) {
  invokeMethod(map, getMapData(map), "removeTopoJSON", layerId)
}

#' @rdname remove
#' @export
clearTopoJSON <- function(map) {
  invokeMethod(map, NULL, "clearTopoJSON")
}
