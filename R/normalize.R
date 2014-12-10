# Given the names of a data frame, list, matrix, etc., take a guess at
# which columns represent latitude and longitude.
# TODO: Add tests
guessLatLongCols <- function(names, stopOnFailure = TRUE,
  shouldPrint = length(names) > 2) {

  lats <- names[grepl("^(lat|latitude)$", names, ignore.case = TRUE)]
  lngs <- names[grepl("^(lng|long|longitude)$", names, ignore.case = TRUE)]

  if (length(lats) == 1 && length(lngs) == 1) {
    if (length(names) > 2) {
      message("Assuming \"", lngs, "\" and \"", lats,
        "\" are longitude and latitude, respectively")
    }
    return(list(lng=lngs, lat=lats))
  }

  # TODO: More helpful error message with appropriate next steps
  if (stopOnFailure) {
    stop("Couldn't infer longitude/latitude columns")
  }

  return(list(lng=NA, lat=NA))
}

resolveFormula <- function(f, data) {
  if (!inherits(f, 'formula'))
    return(f)
  if (length(f) != 2L)
    stop("Unexpected two-sided formula: ", deparse(f))
  eval(f[[2]], data, environment(f))
}

# Given a data object and lng/lat arguments (which may be NULL [meaning infer
# from data], formula [which should be evaluated with respect to the data], or
# vector data [which should be used as-is]) return a lng/lat data frame.
derivePoints <- function(data, lng, lat) {
  if (is.null(lng) || is.null(lat)) {
    pts <- pointData(data)
    if (is.null(lng))
      lng <- pts$lng
    if (is.null(lat))
      lat <- pts$lat
  }

  lng <- resolveFormula(lng, data)
  lat <- resolveFormula(lat, data)
  return(data.frame(lng=lng, lat=lat))
}

# TODO: Add tests
#' @export
pointData <- function(obj) {
  UseMethod("pointData")
}

#' @export
pointData.default <- function(obj) {
  stop("Don't know how to get location data from object of class ", class(obj))
}

#' @export
pointData.data.frame <- function(obj) {
  cols <- guessLatLongCols(names(obj))
  return(data.frame(
    lng = obj[[cols$lng]],
    lat = obj[[cols$lat]]
  ))
}

#' @export
pointData.matrix <- function(obj) {
  dims <- dim(obj)
  if (length(dims) != 2) {
    stop("Point data must be two dimensional")
  }
  if (dims[[2]] != 2) {
    stop("Point data must have exactly two columns")
  }

  data.frame(lng = obj[,1], lat = obj[,2])
}

#' @export
pointData.SpatialPoints <- function(obj) {
  structure(
    as.data.frame(sp::coordinates(obj)),
    names = c("lng", "lat")
  )
}

#' @export
pointData.SpatialPointsDataFrame <- function(obj) {
  structure(
    as.data.frame(sp::coordinates(obj)),
    names = c("lng", "lat")
  )
}

# TODO: Add tests
polygonData <- function(obj) {
  UseMethod("polygonData")
}

polygonData.default <- function(obj) {
  stop("Don't know how to get path data from object of class ", class(obj))
}
polygonData.data.frame <- function(obj) {
  stop("Not implemented")
}
polygonData.matrix <- function(obj) {
  stop("Not implemented")
}
polygonData.Polygon <- function(obj) {
  stop("Not implemented")
}
polygonData.Polygons <- function(obj) {
  stop("Not implemented")
}
polygonData.SpatialPolygons <- function(obj) {
  stop("Not implemented")
}
polygonData.SpatialPolygonsDataFrame <- function(obj) {
  stop("Not implemented")
}
