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

polygonData_sp <- function(obj) {
  structure(
    to_multipolygon_list(obj),
    bbox = sp_bbox(obj)
  )
}

#' @export
polygonData.Polygon <- polygonData_sp
#' @export
polygonData.Polygons <- polygonData_sp
#' @export
polygonData.SpatialPolygons <- polygonData_sp

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
polygonData.Line <- polygonData_sp
#' @export
polygonData.Lines <- polygonData_sp
#' @export
polygonData.SpatialLines <- polygonData_sp

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

# Converters --------------------------------------------------------------

sp_bbox <- function(x) {
  bbox <- sp::bbox(x)
  colnames(bbox) <- NULL
  rownames(bbox) <- c("lng", "lat")
  bbox
}

#' @export
to_multipolygon_list.SpatialPolygons <- function(pgons) {
  lapply(pgons@polygons, to_multipolygon)
}

#' @export
to_multipolygon.Polygons <- function(pgons) {
  if (length(pgons@Polygons) > 1) {
    # If Polygons contains more than one Polygon, then we may be dealing with
    # a polygon with holes or a multipolygon (potentially with holes). Use
    # createPolygonsComment to validate and determine what the situation is.
    comment <- comment(pgons)
    if (is.null(comment) || comment == "FALSE")
      comment <- rgeos::createPolygonsComment(pgons)
    pstatus <- as.integer(strsplit(comment, " ")[[1]])
    lapply(which(pstatus == 0L), function(index) {
      # Return a list of rings, exterior first
      c(
        list(to_ring(pgons@Polygons[[index]])),  # exterior
        lapply(pgons@Polygons[pstatus == index], to_ring)  # holes, if any
      )
    })
  } else {
    to_multipolygon(pgons@Polygons[[1]])
  }
}

#' @export
to_ring.Polygon <- function(pgon) {
  sp_coords(pgon)
}

#' @export
to_multipolygon_list.SpatialLines <- function(lines) {
  lapply(lines@lines, to_multipolygon)
}

#' @export
to_multipolygon.Lines <- function(lines) {
  lapply(lines@Lines, to_polygon)
}

#' @export
to_ring.Line <- function(line) {
  sp_coords(line)
}
