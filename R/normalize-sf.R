# metaData ----------------------------------------------------------------

#' @export
metaData.sf <- function(obj) {
  obj
}

# pointsData --------------------------------------------------------------

#' @export
pointData.sf <- function(obj) {
  pointData(sf::st_geometry(obj))
}

#' @export
pointData.sfc_POINT <- function(obj) {
  if (length(obj) == 0) {
    # If a sfc_GEOMETRY is empty, just return nothing.
    return(data.frame(lng = numeric(0), lat = numeric(0)))
  }

  check_crs(obj)

  structure(
    sf_coords(do.call("rbind", obj)),
    bbox = sf_bbox(obj)
  )
}

#' @export
pointData.POINT <- function(obj) {
  check_crs(obj)

  bbox <- sf_bbox(obj)

  if (!is.matrix(obj)) {
    # st_point can be represented by either a numeric vector or a matrix.
    # Normalize to a matrix.
    #
    # is.matrix(sf::st_point(c(1,1))) # FALSE
    # is.matrix(sf::st_point(matrix(c(1, 1), ncol = 2))) # TRUE
    obj <- matrix(obj, nrow = 1)
  }

  structure(
    sf_coords(obj),
    bbox = bbox
  )
}

#' @export
pointData.sfc_GEOMETRY <- function(obj) {
  if (length(obj) == 0) {
    # If a sfc_GEOMETRY is empty, just return nothing.
    data.frame(lng = numeric(0), lat = numeric(0))
  } else if (all(vapply(obj, inherits, logical(1), "POINT"))) {
    # If it's all POINT objects, then treat it as sfc_POINT.
    pointData.sfc_POINT(obj)
  } else {
    # Otherwise, we don't know what to do. Let pointData.default throw an
    # error.
    NextMethod("pointData")
  }
}

# polygonData -------------------------------------------------------------

#' @export
polygonData.sf <- function(obj) {
  polygonData(sf::st_geometry(obj))
}

#' @export
polygonData.sfc <- function(obj) {
  check_crs(obj)

  structure(
    to_multipolygon_list(obj),
    bbox = sf_bbox(obj)
  )
}

#' @export
polygonData.sfg <- function(obj) {
  structure(
    to_multipolygon_list(obj),
    bbox = sf_bbox(obj)
  )
}


# helpers -----------------------------------------------------------------

check_crs <- function(x) {
  crs <- sf::st_crs(x)

  # Don't have enough information to check
  if (is.na(crs))
    return()

  if (identical(sf::st_is_longlat(x), FALSE)) {
    warning("sf layer is not long-lat data", call. = FALSE)
  }

  if (!grepl("+datum=WGS84", crs$proj4string, fixed = TRUE)) {
    warning(
      "sf layer has inconsistent datum (", crs$proj4string, ").\n",
      "Need '+proj=longlat +datum=WGS84'",
      call. = FALSE
    )
  }

}

sf_coords <- function(x) {
  stopifnot(is.matrix(x) || inherits(x, "XY"))
  structure(
    as.data.frame(unclass(x)),
    names = c("lng", "lat")
  )
}

sf_bbox <- function(x) {
  structure(
    matrix(sf::st_bbox(x), ncol = 2, byrow = FALSE),
    dimnames = list(c("lng", "lat"), NULL)
  )
}

#' @export
to_ring.LINESTRING <- function(x) {
  sf_coords(x)
}

#' @export
to_polygon.POLYGON <- function(x) {
  lapply(x, sf_coords)
}

#' @export
to_multipolygon_list.sfc <- function(x) {
  lapply(x, to_multipolygon)
}

#' @export
to_multipolygon.MULTIPOLYGON <- function(x) {
  lapply(x, function(el) {
    to_polygon(sf::st_polygon(el))
  })
}

#' @export
to_multipolygon.MULTILINESTRING <- function(x) {
  lapply(x, function(el) {
    to_polygon(sf::st_linestring(el))
  })
}
