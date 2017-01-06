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


# polygonData -------------------------------------------------------------

#' @export
polygonData.Polygon <- function(obj) {
  structure(
    list(list(polygon2coords(obj))),
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
    warning("Empty SpatialLinesDataFrame object passed and will be skipped")
    structure(list(), bbox = obj@bbox)
  }
}

#' @export
polygonData.Line <- function(obj) {
  structure(
    list(list(line2coords(obj))),
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

polygon2coords <- function(pgon, bbox = FALSE) {
  df = pointData(sp::coordinates(pgon))
  structure(
    as.list(df),
    bbox = if (bbox) dfbbox(df)
  )
}

sp_bbox <- function(x) {
  bbox <- sp::bbox(x)
  colnames(bbox) <- NULL
  rownames(bbox) <- c("lng", "lat")
  bbox
}

line2coords <- polygon2coords

polygons2coords <- function(pgon, bbox = FALSE) {
  plural2coords(pgon@Polygons[pgon@plotOrder], bbox)
}

lines2coords <- function(lines, bbox = FALSE) {
  plural2coords(lines@Lines, bbox)
}

plural2coords <- function(stuff, bbox) {
  outbbox = bboxNull
  lapply(stuff, function(pgon) {
    coords = polygon2coords(pgon)
    if (bbox)
      outbbox <<- bboxAdd(outbbox, attr(coords, "bbox", exact = TRUE))
    structure(coords, bbox = NULL)
  }) %>% structure(bbox = if (bbox) outbbox)
}

