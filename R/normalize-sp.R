# metaData --------------------------------------------------------

#' @export
metaData.SpatialPointsDataFrame <- function(obj) obj@data
#' @export
metaData.SpatialLinesDataFrame <- function(obj) obj@data
#' @export
metaData.SpatialPolygonsDataFrame <- function(obj) obj@data

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

  list(list(to_polygon(obj)))
  structure(
    to_polygon(obj) %>%
      list() %>%  # multipolygon
      list(),     # list of multipolygons
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.Polygons <- polygonData.Polygon

#' @export
polygonData.SpatialPolygons <- function(obj) {
  structure(
    lapply(obj@polygons, function(pgon) {
      to_polygon(pgon) %>%
        list() # multipolygon
    }),
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
    to_polygon(obj) %>%
      list() %>% # multipolygon
      list(),    # list of multipolygons
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.Lines <- function(obj) {
  structure(
    to_polygon(obj) %>%
      list() %>% # multipolygon
      list(),    # list of multipolygons
    bbox = sp_bbox(obj)
  )
}
#' @export
polygonData.SpatialLines <- function(obj) {
  structure(
    lapply(obj@lines, function(line) {
      to_polygon(line) %>%
        list() # multipolygon
    }),
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

to_polygon.Polygons <- function(pgons) {
  lapply(pgons@Polygons[pgons@plotOrder], sp_coords)
}

to_polygon.Polygon <- function(pgon) {
  list(sp_coords(pgon))
}

to_polygon.Lines <- function(lines) {
  lapply(lines@Lines, sp_coords)
}

to_polygon.Line <- function(line) {
  list(sp_coords(line))
}
