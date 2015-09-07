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

#' Make awesome-icon set
#'
#' @param ... icons created from \code{\link{makeAwesomeIcon}()}
#' @export
#' @examples
#'
#' iconSet = awesomeIconList(
#'   home = makeAwesomeIcon(icon='Home', prefix='fa'),
#'   flag = makeAwesomeIcon(icon='Flag', prefix='fa')
#' )
#'
#' iconSet[c('home', 'flag')]
awesomeIconList = function(...) {
  res = structure(
    list(...),
    class = "leaflet_awesome_icon_set"
  )
  cls = unlist(lapply(res, inherits, 'leaflet_awesome_icon'))
  if (any(!cls))
    stop('Arguments passed to awesomeIconList() must be icon objects returned from makeAwesomeIcon()')
  res
}

#' @export
`[.leaflet_awesome_icon_set` = function(x, i) {
  if (is.factor(i)) {
    i = as.character(i)
  }

  if (!is.character(i) && !is.numeric(i) && !is.integer(i)) {
    stop("Invalid subscript type '", typeof(i), "'")
  }

  structure(.subset(x, i), class = "leaflet_awesome_icon_set")
}

awesomeIconSetToAwesomeIcons = function(x) {
  # c("icon", "prefix", ...)
  cols = names(formals(makeAwesomeIcon))
  # list(icon = "icon", prefix = "prefix", ...)
  cols = structure(as.list(cols), names = cols)

  # Construct an equivalent output to awesomeIcons().
  filterNULL(lapply(cols, function(col) {
    # Pluck the `col` member off of each item in awesomeIconObjs and put them in an
    # unnamed list (or vector if possible).
    colVals = unname(sapply(x, `[[`, col))

    # If this is the common case where there's lots of values but they're all
    # actually the same exact thing, then just return one value; this will be
    # much cheaper to send to the client, and we'll do recycling on the client
    # side anyway.
    if (length(unique(colVals)) == 1) {
      return(colVals[[1]])
    } else {
      return(colVals)
    }
  }))
}

#' Make Awesome Icon
#'
#' @inheritParams awesomeIcons
#' @export
makeAwesomeIcon <- function(
  icon = NULL,
  prefix = NULL,
  markerColor = NULL,
  iconColor = NULL,
  spin = NULL,
  extraClasses = NULL
) {
  icon = filterNULL(list(
    icon= icon, prefix = prefix, markerColor = markerColor, iconColor = iconColor,
    spin = spin, extraClasses = extraClasses
  ))
  structure(icon, class = "leaflet_awesome_icon")
}

#' Create a list of awesome icon data
#'
#' An icon can be represented as a list of the form \code{list(icon,
#' prefix, ...)}. This function is vectorized over its arguments to create a
#' list of icon data. Shorter argument values will be re-cycled. \code{NULL}
#' values for these arguments will be ignored.
#' @param
#' icon,prefix,markerColor,iconColor,spin,extraClasses
#' see \url{https://github.com/lvoogdt/Leaflet.awesome-markers}
#' @return A list of awesome-icon data that can be passed to the \code{icon} argument of
#'   \code{\link{addAwesomeMarkers}()}.
#' @export
awesomeIcons <- function(
  icon = NULL,
  prefix = NULL,
  markerColor = NULL,
  iconColor = NULL,
  spin = NULL,
  extraClasses = NULL

) {
  filterNULL(list(
    icon= icon, prefix = prefix, markerColor = markerColor, iconColor = iconColor,
    spin = spin, extraClasses = extraClasses
  ))
}

#' Add Awesome Markers
#' @param map the map to add awesome Markers to.
#' @param lng a numeric vector of longitudes, or a one-sided formula of the form
#'   \code{~x} where \code{x} is a variable in \code{data}; by default (if not
#'   explicitly provided), it will be automatically inferred from \code{data} by
#'   looking for a column named \code{lng}, \code{long}, or \code{longitude}
#'   (case-insensitively)
#' @param lat a vector of latitudes or a formula (similar to the \code{lng}
#'   argument; the names \code{lat} and \code{latitude} are used when guessing
#'   the latitude column from \code{data})
#' @param popup a character vector of the HTML content for the popups (you are
#'   recommended to escape the text using \code{\link[htmltools]{htmlEscape}()}
#'   for security reasons)
#' @param layerId the layer id
#' @param group the name of the group the newly created layers should belong to
#'   (for \code{\link{clearGroup}} and \code{\link{addLayersControl}} purposes).
#'   Human-friendly group names are permitted--they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g. markers and polygons) can share the same group name.
#' @param data the data object from which the argument values are derived; by
#'   default, it is the \code{data} object provided to \code{leaflet()}
#'   initially, but can be overridden
#' @param icon the icon(s) for markers;
#' @param label a character vector of the HTML content for the labels
#' @param labelOptions A Vector of \code{\link{labelOptions}} to provide label
#' options for each label. Default \code{NULL}
#' @param clusterOptions if not \code{NULL}, markers will be clustered using
#'   \href{https://github.com/Leaflet/Leaflet.markercluster}{Leaflet.markercluster};
#'    you can use \code{\link{markerClusterOptions}()} to specify marker cluster
#'   options
#' @param clusterId the id for the marker cluster layer
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements
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
    # If formulas are present, they must be evaluated first so we can pack the
    # resulting values
    icon = evalFormula(list(icon), data)[[1]]

    if (inherits(icon, "leaflet_awesome_icon_set")) {
      icon = awesomeIconSetToAwesomeIcons(icon)
    }
    icon = filterNULL(icon)
  }

  if (!is.null(clusterOptions))
    map$dependencies = c(map$dependencies, markerClusterDependencies())

  pts = derivePoints(data, lng, lat, missing(lng), missing(lat), "addAwesomeMarkers")
  invokeMethod(
    map, data, 'addAwesomeMarkers', pts$lat, pts$lng, icon, layerId, group, options, popup,
    clusterOptions, clusterId, safeLabel(label, data), labelOptions
  ) %>% expandLimits(pts$lat, pts$lng)
}

