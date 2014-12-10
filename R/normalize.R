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
pointData <- function(obj, dataContext) {
  UseMethod("pointData")
}

pointData.default <- function(obj, dataContext) {
  stop("Don't know how to get location data from object of class ", class(obj))
}

pointData.data.frame <- function(obj, dataContext) {
  cols <- guessLatLongCols(names(obj))
  return(data.frame(
    lng = obj[[cols$lng]],
    lat = obj[[cols$lat]]
  ))
}

pointData.formula <- function(obj, dataContext) {
  if (length(obj) == 3) {
    # binary formula
    lng <- eval(obj[[2]], dataContext, environment(obj))
    lat <- eval(obj[[3]], dataContext, environment(obj))
    return(pointData(cbind(lng, lat), dataContext))
  } else if (length(obj) == 2) {
    # unary formula
    return(pointData(eval(obj[[2]], dataContext, environment(obj))))
  }
}

pointData.character <- function(obj, dataContext) {
  if (length(obj) != 2) {
    # TODO: Better error message
    stop("Point data character indices should be length 2")
  }

  return(structure(
    dataContext[, obj],
    names = c("lng", "lat")
  ))
}

pointData.matrix <- function(obj, dataContext) {
  dims <- dim(obj)
  if (length(dims) != 2) {
    stop("Point data must be two dimensional")
  }
  if (dims[[2]] != 2) {
    stop("Point data must have exactly two columns")
  }

  data.frame(lng = obj[,1], lat = obj[,2])
}

pointData.SpatialPoints <- function(obj, dataContext) {
  structure(
    as.data.frame(sp::coordinates(obj)),
    names = c("lng", "lat")
  )
}

pointData.SpatialPointsDataFrame <- function(obj, dataContext) {
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
