leafletAwesomeMarkersDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-awesomemarkers",
      "2.0.3",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      script = c("leaflet.awesome-markers.min.js"),
      stylesheet = c("leaflet.awesome-markers.css")
    )
  )
}

leafletAmBootstrapDependencies <- function(map) {
  list(
    htmltools::htmlDependency(
      "bootstrap",
      "3.3.7",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      script = c("bootstrap.min.js"),
      stylesheet = c("bootstrap.min.css")
    )
  )
}

# Required for using BootStrap Fonts
# @param map the map to add awesome Markers to.
addBootstrap <- function(map) {
  map$dependencies <- c(map$dependencies, leafletAmBootstrapDependencies())
  map
}

leafletAmFontAwesomeDependencies <- function(map) {
  list(
    htmltools::htmlDependency(
      "fontawesome",
      "4.7.0",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      stylesheet = c("font-awesome.min.css")
    )
  )
}

# Required for using Font-Awesome Fonts
# @param map the map to add awesome Markers to.
addFontAwesome <- function(map) {
  map$dependencies <- c(map$dependencies, leafletAmFontAwesomeDependencies())
  map
}

leafletAmIonIconDependencies <- function(map) {
  list(
    htmltools::htmlDependency(
      "ionicons",
      "2.0.1",
      system.file("htmlwidgets/plugins/Leaflet.awesome-markers", package = "leaflet"),
      stylesheet = c("ionicons.min.css")
    )
  )
}

# Required for using IonIcon Fonts
# @param map the map to add awesome Markers to.
addIonIcon <- function(map) {
  map$dependencies <- c(map$dependencies, leafletAmIonIconDependencies())
  map
}

#' Make awesome-icon set
#'
#' @param ... icons created from \code{\link{makeAwesomeIcon}()}
#' @export
#' @examples
#'
#' iconSet <- awesomeIconList(
#'   home = makeAwesomeIcon(icon = "Home", library = "fa"),
#'   flag = makeAwesomeIcon(icon = "Flag", library = "fa")
#' )
#'
#' iconSet[c("home", "flag")]
awesomeIconList <- function(...) {
  res <- structure(
    list(...),
    class = "leaflet_awesome_icon_set"
  )
  cls <- unlist(lapply(res, inherits, "leaflet_awesome_icon"))
  if (any(!cls))
    stop("Arguments passed to awesomeIconList() must be icon objects returned from makeAwesomeIcon()") # nolint
  res
}

#' @export
`[.leaflet_awesome_icon_set` <- function(x, i) {
  if (is.factor(i)) {
    i <- as.character(i)
  }

  if (!is.character(i) && !is.numeric(i) && !is.integer(i)) {
    stop("Invalid subscript type '", typeof(i), "'")
  }

  structure(.subset(x, i), class = "leaflet_awesome_icon_set")
}

awesomeIconSetToAwesomeIcons <- function(x) {
  # c("icon", "library", ...)
  cols <- names(formals(makeAwesomeIcon))
  # list(icon = "icon", library = "library", ...)
  cols <- structure(as.list(cols), names = cols)

  # Construct an equivalent output to awesomeIcons().
  filterNULL(lapply(cols, function(col) {
    # Pluck the `col` member off of each item in awesomeIconObjs and put them in an
    # unnamed list (or vector if possible).
    colVals <- unname(sapply(x, `[[`, col))

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
  icon = "home",
  library = "glyphicon",
  markerColor = "blue",
  iconColor = "white",
  spin = FALSE,
  extraClasses = NULL,
  squareMarker = FALSE,
  iconRotate = 0,
  fontFamily = "monospace",
  text = NULL
) {
  if (!inherits(library, "formula")) {
    verifyIconLibrary(library)
  }

  icon <- filterNULL(list(
    icon = icon, library = library, markerColor = markerColor,
    iconColor = iconColor, spin = spin, extraClasses = extraClasses,
    squareMarker = squareMarker, iconRotate = iconRotate,
    font = fontFamily, text = text

  ))
  structure(icon, class = "leaflet_awesome_icon")
}

#' Create a list of awesome icon data see
#' \url{https://github.com/lvoogdt/Leaflet.awesome-markers}
#'
#' An icon can be represented as a list of the form \code{list(icon, library,
#' ...)}. This function is vectorized over its arguments to create a list of
#' icon data. Shorter argument values will be re-cycled. \code{NULL} values for
#' these arguments will be ignored.
#' @param icon Name of the icon
#' @param library Which icon library. Default \code{"glyphicon"}, other possible
#'   values are \code{"fa"} (fontawesome) or \code{"ion"} (ionicons).
#' @param markerColor Possible values are \code{"red"}, \code{"darkred"}, \code{"lightred"}, \code{"orange"},
#' \code{"beige"}, \code{"green"}, \code{"darkgreen"}, \code{"lightgreen"}, \code{"blue"},
#' \code{"darkblue"}, \code{"lightblue"}, \code{"purple"}, \code{"darkpurple"}, \code{"pink"},
#' \code{"cadetblue"}, \code{"white"}, \code{"gray"}, \code{"lightgray"}, \code{"black"}
#' @param iconColor The color to use for the icon itself. Use any CSS-valid
#'   color (hex, rgba, etc.) or a named web color.
#' @param spin If \code{TRUE}, make the icon spin (only works when \code{library
#'   = "fa"})
#' @param extraClasses Additional css classes to include on the icon.
#' @return A list of awesome-icon data that can be passed to the \code{icon}
#' @param squareMarker Whether to use a square marker.
#' @param iconRotate Rotate the icon by a given angle.
#' @param fontFamily Used when \code{text} option is specified.
#' @param text Use this text string instead of an icon.
#'   argument of \code{\link{addAwesomeMarkers}()}.
#' @export
awesomeIcons <- function(
  icon = "home",
  library = "glyphicon",
  markerColor = "blue",
  iconColor = "white",
  spin = FALSE,
  extraClasses = NULL,
  squareMarker = FALSE,
  iconRotate = 0,
  fontFamily = "monospace",
  text = NULL

) {
  if (!inherits(library, "formula")) {
    verifyIconLibrary(library)
  }

  filterNULL(list(
    icon = icon, library = library, markerColor = markerColor,
    iconColor = iconColor, spin = spin, extraClasses = extraClasses,
    squareMarker = squareMarker, iconRotate = iconRotate,
    font = fontFamily, text = text
  ))
}

verifyIconLibrary <- function(library) {
  bad <- library[!(library %in% c("glyphicon", "fa", "ion"))]
  if (length(bad) > 0) {
    stop("Invalid icon library names: ", paste(unique(bad), collapse = ", "))
  }
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
#' @param popupOptions A Vector of \code{\link{popupOptions}} to provide popups
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
addAwesomeMarkers <- function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
  icon = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = getMapData(map)
) {
  if (missing(labelOptions)) labelOptions <- labelOptions()
  map$dependencies <- c(map$dependencies, leafletAwesomeMarkersDependencies())

  if (!is.null(icon)) {
    # If formulas are present, they must be evaluated first so we can pack the
    # resulting values
    icon <- evalFormula(list(icon), data)[[1]]

    if (inherits(icon, "leaflet_awesome_icon_set")) {
      icon <- awesomeIconSetToAwesomeIcons(icon)
    }
    icon <- filterNULL(icon)
    verifyIconLibrary(icon$library)
    lapply(unique(icon$library), function(lib) {
      libFunc <- switch(lib,
        glyphicon = addBootstrap,
        fa = addFontAwesome,
        ion = addIonIcon,
        default = stop("Unknown icon library \"", lib, "\"")
      )
      map <<- libFunc(map)
    })
    icon$prefix <- icon$library
    icon$library <- NULL
  }

  if (!is.null(clusterOptions))
    map$dependencies <- c(map$dependencies, markerClusterDependencies())

  pts <- derivePoints(data, lng, lat, missing(lng), missing(lat), "addAwesomeMarkers")
  invokeMethod(
    map, data, "addAwesomeMarkers", pts$lat, pts$lng, icon, layerId,
    group, options, popup, popupOptions,
    clusterOptions, clusterId, safeLabel(label, data), labelOptions,
    getCrosstalkOptions(data)
  ) %>% expandLimits(pts$lat, pts$lng)
}
