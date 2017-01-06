# doResolveFormula --------------------------------------------------------

#' @export
doResolveFormula.SpatialPointsDataFrame <- function(data, f) {
  doResolveFormula(data@data, f)
}

#' @export
doResolveFormula.SpatialLinesDataFrame <- doResolveFormula.SpatialPointsDataFrame

#' @export
doResolveFormula.SpatialPolygonsDataFrame <- doResolveFormula.SpatialPointsDataFrame

# pointData ---------------------------------------------------------------

#' @export
pointData.SpatialPoints <- function(obj) {
  sp_coords(obj)
}

#' @export
pointData.SpatialPointsDataFrame <- function(obj) {
  sp_coords(obj)
}


# polygonData -------------------------------------------------------------

#' @export
polygonData.Polygon <- function(obj) {
  structure(
    list(list(sp_coords(obj))),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.Polygons <- function(obj) {
  structure(
    list(polygons2coords(obj)),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.SpatialPolygons <- function(obj) {
  structure(
    lapply(obj@polygons, polygons2coords),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.SpatialPolygonsDataFrame <- function(obj) {
  if (length(obj@polygons) > 0) {
    polygonData(sp::polygons(obj))
  } else {
    warning("Empty SpatialPolygonsDataFrame object passed and will be skipped")
    structure(list(), bbox = obj@bbox)
  }
}

#' @export
polygonData.Line <- function(obj) {
  structure(
    list(list(sp_coords(obj))),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.Lines <- function(obj) {
  structure(
    list(lines2coords(obj)),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.SpatialLines <- function(obj) {
  structure(
    lapply(obj@lines, lines2coords),
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.SpatialLinesDataFrame <- function(obj) {
  if (length(obj@lines) > 0) {
    polygonData(sp::SpatialLines(obj@lines))
  } else {
    warning("Empty SpatialLinesDataFrame object passed and will be skipped")
    structure(list(), bbox=obj@bbox)
  }
}

# Helpers -----------------------------------------------------------------

sp_coords <- function(x) {
  structure(
    as.data.frame(sp::coordinates(x)),
    names = c("lng", "lat")
  )
}

sp_bbox <- function(x) {
  bbox <- sp::bbox(x)
  colnames(bbox) <- NULL
  rownames(bbox) <- c("lng", "lat")
  bbox
}

polygons2coords <- function(pgon) {
  lapply(pgon@Polygons[pgon@plotOrder], sp_coords)
}

lines2coords <- function(lines) {
  lapply(lines@Lines, sp_coords)
}
