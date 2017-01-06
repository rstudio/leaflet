# Given the names of a data frame, list, matrix, etc., take a guess at
# which columns represent latitude and longitude.
guessLatLongCols <- function(names, stopOnFailure = TRUE) {

  lats = names[grep("^(lat|latitude)$", names, ignore.case = TRUE)]
  lngs = names[grep("^(lon|lng|long|longitude)$", names, ignore.case = TRUE)]

  if (length(lats) == 1 && length(lngs) == 1) {
    if (length(names) > 2) {
      message("Assuming '", lngs, "' and '", lats,
        "' are longitude and latitude, respectively")
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
  if (!inherits(f, 'formula')) return(f)
  if (length(f) != 2L) stop("Unexpected two-sided formula: ", deparse(f))

  doResolveFormula(data, f)
}

doResolveFormula <- function(data, f) {
  UseMethod("doResolveFormula")
}

#' @export
doResolveFormula.data.frame <- function(data, f) {
  eval(f[[2]], data, environment(f))
}

#' @export
doResolveFormula.SharedData <- function(data, f) {
  doResolveFormula(data$data(withSelection = TRUE, withFilter = FALSE, withKey = TRUE), f)
}

#' @export
doResolveFormula.map <- function(data, f) {
  eval(f[[2]], data, environment(f))
}

#' @export
doResolveFormula.list <- function(data, f) {
  eval(f[[2]], data, environment(f))
}

#' @export
doResolveFormula.SpatialPointsDataFrame <- function(data, f) {
  doResolveFormula(data@data, f)
}

#' @export
doResolveFormula.SpatialLinesDataFrame <- doResolveFormula.SpatialPointsDataFrame

#' @export
doResolveFormula.SpatialPolygonsDataFrame <- doResolveFormula.SpatialPointsDataFrame

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
derivePoints <- function(data, lng, lat, missingLng, missingLat, funcName) {
  if (missingLng || missingLat) {
    if (is.null(data)) {
      stop("Point data not found; please provide ", funcName,
        " with data and/or lng/lat arguments")
    }
    pts = pointData(data)
    if (is.null(lng)) lng = pts$lng
    if (is.null(lat)) lat = pts$lat
  }

  lng = resolveFormula(lng, data)
  lat = resolveFormula(lat, data)

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
derivePolygons <- function(data, lng, lat, missingLng, missingLat, funcName) {
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
  lng = resolveFormula(lng, data)
  lat = resolveFormula(lat, data)

  df <- validateCoords(lng, lat, funcName)
  polygonData(cbind(df$lng, df$lat))
}

# TODO: Add tests
pointData <- function(obj) {
  UseMethod("pointData")
}

#' @export
pointData.default <- function(obj) {
  stop("Don't know how to get location data from object of class ",
    class(obj)[[1]])
}

#' @export
pointData.data.frame <- function(obj) {
  cols = guessLatLongCols(names(obj))
  data.frame(
    lng = obj[[cols$lng]],
    lat = obj[[cols$lat]]
  )
}

#' @export
pointData.matrix <- function(obj) {
  dims = dim(obj)
  if (length(dims) != 2) {
    stop("Point data must be two dimensional")
  }
  if (dims[[2]] != 2) {
    stop("Point data must have exactly two columns")
  }

  data.frame(lng = obj[, 1], lat = obj[, 2])
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

#' @export
pointData.SharedData <- function(obj) {
  pointData(obj$data(withSelection = FALSE,
    withFilter = FALSE, withKey = FALSE))
}

# A simple polygon is a list(lng=numeric(), lat=numeric()). A compound polygon
# is a list of simple polygons. This function returns a list of compound
# polygons, so list(list(list(lng=..., lat=...))). There is also a bbox
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
  makePolyList(pointData.matrix(obj))
}
#' @export
polygonData.Polygon <- function(obj) {
  coords = polygon2coords(obj)
  structure(
    list(list(coords)),
    bbox = attr(coords, "bbox", exact = TRUE)
  )
}
#' @export
polygonData.Polygons <- function(obj) {
  coords = polygons2coords(obj)
  structure(
    list(structure(coords, bbox = NULL)),
    bbox = attr(coords, "bbox", exact = TRUE)
  )
}
#' @export
polygonData.SpatialPolygons <- function(obj) {
  lapply(obj@polygons, polygons2coords, bbox = FALSE) %>%
    structure(bbox = obj@bbox)
}
#' @export
polygonData.SpatialPolygonsDataFrame <- function(obj) {
  #polygonData(sp::polygons(obj))
  if(length(obj@polygons)>0) {
    polygonData(sp::SpatialPolygons(obj@polygons))
  } else {
    warning("Empty SpatialLinesDataFrame object passed and will be skipped")
    structure(list(), bbox=obj@bbox)
  }
}
#' @export
polygonData.map <- function(obj) {
  polygonData(cbind(obj$x, obj$y))
}

#' @export
polygonData.Line <- function(obj) {
  coords = line2coords(obj)
  structure(
    list(list(coords)),
    bbox = attr(coords, "bbox", exact = TRUE)
  )
}
#' @export
polygonData.Lines <- function(obj) {
  coords = lines2coords(obj)
  structure(
    list(structure(coords, bbox = NULL)),
    bbox = attr(coords, "bbox", exact = TRUE)
  )
}
#' @export
polygonData.SpatialLines <- function(obj) {
  lapply(obj@lines, lines2coords, bbox = FALSE) %>%
    structure(bbox = obj@bbox)
}
#' @export
polygonData.SpatialLinesDataFrame <- function(obj) {
  if(length(obj@lines)>0) {
    polygonData(sp::SpatialLines(obj@lines))
  } else {
    warning("Empty SpatialLinesDataFrame object passed and will be skipped")
    structure(list(), bbox=obj@bbox)
  }
}

#' @export
polygonData.SharedData <- function(obj) {
  polygonData(obj$data(withSelection = FALSE,
    withFilter = FALSE, withKey = FALSE))
}

dfbbox <- function(df) {
  suppressWarnings(rbind(
    lng = range(df$lng, na.rm = TRUE),
    lat = range(df$lat, na.rm = TRUE)
  ))
}
makePolyList <- function(df) {
  lng = df$lng
  lat = df$lat
  i = is.na(lat)
  chunks = cumsum(i)[!i]
  unname(split(data.frame(lng=lng[!i], lat=lat[!i]), chunks)) %>%
    lapply(as.list) %>%
    lapply(list) %>%
    structure(bbox = dfbbox(df))
}

polygon2coords <- function(pgon, bbox = TRUE) {
  df = pointData(sp::coordinates(pgon))
  structure(
    as.list(df),
    bbox = if (bbox) dfbbox(df)
  )
}
line2coords = polygon2coords

plural2coords <- function(stuff, bbox) {
  outbbox = bboxNull
  lapply(stuff, function(pgon) {
    coords = polygon2coords(pgon)
    if (bbox)
      outbbox <<- bboxAdd(outbbox, attr(coords, "bbox", exact = TRUE))
    structure(coords, bbox = NULL)
  }) %>% structure(bbox = if (bbox) outbbox)
}

polygons2coords <- function(pgon, bbox = TRUE) {
  plural2coords(pgon@Polygons[pgon@plotOrder], bbox)
}

lines2coords <- function(lines, bbox = TRUE) {
  plural2coords(lines@Lines, bbox)
}
