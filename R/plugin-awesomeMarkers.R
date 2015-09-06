leafletAwesomeMarkersDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-awesomemarkers",
      "2.0.2",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      script = c('leaflet.awesome-markers.min.js','bootstrap.min.js'),
      stylesheet = c('leaflet.awesome-markers.css','bootstrap.min.css',
                     'font-awesome.min.css','ionicons.min.css')
    )
  )
}

#' Creates a Marker with awesome-marker icons
#'
#' @param
#' icon,prefix,markerColor,iconColor,spin,extraClasses
#' see \url{https://github.com/lvoogdt/Leaflet.awesome-markers}
#' @describeIn awesome-markers Create Awesome Markers
#' @export
makeAwesomeIcon <- function(
#  iconSize = c(35, 45),
#  iconAnchor =   c(17, 42),
#  popupAnchor = c(1, -32),
#  shadowAnchor = c(10, 12),
#  shadowSize = c(36, 16),
  icon = NULL,
  prefix = NULL,
  markerColor = NULL,
  iconColor = NULL,
  spin = NULL,
  extraClasses = NULL
) {
  icon = filterNULL(list(
    #iconSize = iconSize, iconAnchor = iconAnchor,
    #popupAnchor = popupAnchor, shadowAnchor = shadowAnchor, shadowSize = shadowSize,
    icon= icon, prefix = prefix, markerColor = markerColor, iconColor = iconColor,
    spin = spin, extraClasses = extraClasses
  ))
  structure(icon, class = "leaflet_awesome_icon")
}

#' @param icon the icon(s) for markers;
#' @param label a character vector of the HTML content for the labels
#' @param labelOptions A Vector of \code{\link{labelOptions}} to provide label
#' options for each label. Default \code{NULL}
#' @param clusterOptions if not \code{NULL}, markers will be clustered using
#'   \href{https://github.com/Leaflet/Leaflet.markercluster}{Leaflet.markercluster};
#'    you can use \code{\link{markerClusterOptions}()} to specify marker cluster
#'   options
#' @param clusterId the id for the marker cluster layer
#' @describeIn awesome-markers add Awesome Markers to a Map | Layer
#' @export
addAwesomeMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
  icon = NULL,
  popup = NULL,
  label = NULL,
  labelOptions = NULL,
  options = markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  map$dependencies <- c(map$dependencies, leafletAwesomeMarkersDependencies())

  if (!is.null(icon)) {
    if (!inherits(icon, "leaflet_awesome_icon")) {
      stop('Arguments passed to iconList() must be icon objects returned from makeAwesomeIcon()')
    }
  }

  if (!is.null(clusterOptions))
    map$dependencies = c(map$dependencies, markerClusterDependencies())

  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addAwesomeMarkers")
  invokeMethod(
    map, data, 'addAwesomeMarkers', pts$lat, pts$lng, icon, layerId, group, options, popup,
    clusterOptions, clusterId, safeLabel(label, data), labelOptions
  ) %>% expandLimits(pts$lat, pts$lng)
}

