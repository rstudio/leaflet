# Given the names of a data frame, list, matrix, etc., take a guess at
# which columns represent latitude and longitude.
guessLatLongCols <- function(names, stopOnFailure = TRUE) {

  lats <- names[grep("^(lat|latitude)$", names, ignore.case = TRUE)]
  lngs <- names[grep("^(lon|lng|long|longitude)$", names, ignore.case = TRUE)]

  if (length(lats) == 1 && length(lngs) == 1) {
    if (length(names) > 2) {
      message("Assuming \"", lngs, "\" and \"", lats,
        "\" are longitude and latitude, respectively")
    }
    return(list(lng = lngs, lat = lats))
  }

  # TODO: More helpful error message with appropriate next steps
  if (stopOnFailure) {
    stop("Couldn't infer longitude/latitude columns")
  }

  list(lng = NA, lat = NA)
}

resolveFormula <- function(f, data) {
  if (!inherits(f, "formula")) return(f)
  if (length(f) != 2L) stop("Unexpected two-sided formula: ", deparse(f))

  eval(f[[2]], metaData(data), environment(f))
}

metaData <- function(obj) UseMethod("metaData")
#' @export
metaData.data.frame <- function(obj) obj
#' @export
metaData.list <- function(obj) obj


#' Given a data object and lng/lat arguments (which may be NULL [meaning infer
#' from data], formula [which should be evaluated with respect to the data], or
#' vector data [which should be used as-is]) return a lng/lat data frame.
#' @param data map data
#' @param lng longitude
#' @param lat latitude
#' @param missingLng whether lng is missing
#' @param missingLat whether lat is missing
#' @param funcName Name of calling function (for logging)
#' @export
derivePoints <- function(data, lng = NULL, lat = NULL,
                         missingLng = missing(lng),
                         missingLat = missing(lat),
                         funcName = "f") {
  if (missingLng || missingLat) {
    if (is.null(data)) {
      stop("Point data not found; please provide ", funcName,
        " with data and/or lng/lat arguments")
    }
    pts <- pointData(data)
    if (is.null(lng)) lng <- pts$lng
    if (is.null(lat)) lat <- pts$lat
  }

  lng <- resolveFormula(lng, data)
  lat <- resolveFormula(lat, data)

  validateCoords(lng, lat, funcName)
}

#' Given a data object and lng/lat arguments (which may be NULL [meaning infer
#' from data], formula [which should be evaluated with respect to the data], or
#' vector data [which should be used as-is]) return a spatial object
#' @param data map data
#' @param lng longitude
#' @param lat latitude
#' @param missingLng whether lng is missing
#' @param missingLat whether lat is missing
#' @param funcName Name of calling function (for logging)
#' @export
derivePolygons <- function(data, lng = NULL, lat = NULL,
                           missingLng = missing(lng),
                           missingLat = missing(lat),
                           funcName = "f") {
  if (missingLng != missingLat) {
    stop(funcName, " must be called with both lng and lat, or with neither.")
  }
  if (missingLng) {
    if (is.null(data)) {
      stop("Polygon data not found; please provide ", funcName,
        " with data and/or lng/lat arguments")
    }
    return(polygonData(data))
  }
  lng <- resolveFormula(lng, data)
  lat <- resolveFormula(lat, data)

  df <- validateCoords(lng, lat, funcName, mode = "polygon")
  polygonData(cbind(df$lng, df$lat))
}

# TODO: Add tests
pointData <- function(obj) {
  UseMethod("pointData")
}

#' @export
pointData.default <- function(obj) {
  stop("Don't know how to get location data from object of class ",
    paste(class(obj), collapse = ","))
}

#' @export
pointData.data.frame <- function(obj) {
  cols <- guessLatLongCols(names(obj))
  data.frame(
    lng = obj[[cols$lng]],
    lat = obj[[cols$lat]]
  )
}

#' @export
pointData.matrix <- function(obj) {
  checkMatrix(obj)
  data.frame(lng = obj[, 1], lat = obj[, 2])
}

# A simple polygon is a list(lng = numeric(), lat = numeric()). A compound polygon
# is a list of simple polygons. This function returns a list of compound
# polygons, so list(list(list(lng = ..., lat = ...))). There is also a bbox
# attribute attached that gives the bounding box, same as sp::bbox().
polygonData <- function(obj) {
  UseMethod("polygonData")
}

#' @export
polygonData.default <- function(obj) {
  stop("Don't know how to get path data from object of class ", class(obj)[[1]])
}

#' @export
polygonData.matrix <- function(obj) {
  checkMatrix(obj)
  df <- data.frame(lng = obj[, 1], lat = obj[, 2])

  bbox <- suppressWarnings(rbind(
    lng = range(df$lng, na.rm = TRUE),
    lat = range(df$lat, na.rm = TRUE)
  ))

  # Split into polygons wherever there is a row of NA
  missing <- !stats::complete.cases(df)
  group <- cumsum(missing)
  polys <- split(df[!missing, , drop = FALSE], group[!missing]) # nolint

  structure(
    lapply(unname(polys), function(x) list(list(x))),
    bbox = bbox
  )
}


checkMatrix <- function(x) {
  if (length(dim(x)) != 2) {
    stop("Matrix data must be two dimensional", call. = FALSE)
  }
  if (ncol(x) != 2) {
    stop("Matrix data must have exactly two columns", call. = FALSE)
  }
}


# ==== Multi-polygon conversion generic functions ====
#
# The return value from the polygonData generic function is a list of
# multipolygons, plus a bbox attribute.
#
# We want to implement polygonData generics for:
#
# - lists of multipolygons
# - individual multipolygons
# - lists of polygons
# - individual polygons
# - lists of multipolylines
# - individual multipolylines
# - lists of polylines
# - individual polylines
#
# The previous implementation of this logic tried to directly implement
# polygonData for each of the above (or at least as many as we could until the
# scheme fell apart). This doesn't work because the shape of the return value
# of polygonData must always be the same (a list of multipolygons) and always
# includes the bbox attribute which is not needed for inner data structures.
# In other words, polygonData.MULTIPOLYGON can't just do something like
# lapply(obj, polygonData.POLYGON) because polygonData.POLYGON has too much
# structure.
#
# The new scheme defines a family of conversion functions:
#
# - to_multipolygon_list
# - to_multipolygon
# - to_polygon
# - to_ring
#
# Each of the specific sp/sf classes need only implement whichever ONE of those
# actually makes sense (e.g. to_multipolygon_list.sfc,
# to_multipolygon.MULTIPOLYGON, to_polygon.POLYGON, to_ring.LINESTRING). The
# higher-level polygonData wrappers will simply call to_multipolygon_list(x),
# and the default implementations of those methods will fall through to the next
# level until a match is found.

to_multipolygon_list <- function(x) {
  UseMethod("to_multipolygon_list")
}

#' @export
to_multipolygon_list.default <- function(x) {
  list(to_multipolygon(x))
}

to_multipolygon <- function(x) {
  UseMethod("to_multipolygon")
}

#' @export
to_multipolygon.default <- function(x) {
  list(to_polygon(x))
}

to_polygon <- function(x) {
  UseMethod("to_polygon")
}

#' @export
to_polygon.default <- function(x) {
  list(to_ring(x))
}

to_ring <- function(x) {
  UseMethod("to_ring")
}

#' @export
to_ring.default <- function(x) {
  stop("Don't know how to get polygon data from object of class ",
    paste(class(x), collapse = ","))
}
