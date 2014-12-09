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

# TODO: Add tests
pointData <- function(obj) {
  UseMethod("pointData")
}

pointData.default <- function(obj) {
  stop("Don't know how to get location data from object of class ", class(obj))
}

pointData.data.frame <- function(obj) {
  cols <- guessLatLongCols(names(obj))
  return(data.frame(
    lng = obj[cols$lng],
    lat = obj[cols$lat]
  ))
}

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

pointData.SpatialPoints <- function(obj) {
  structure(
    as.data.frame(sp::coordinates(obj)),
    names = c("lng", "lat")
  )
}

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
