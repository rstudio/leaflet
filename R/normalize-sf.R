# metaData ----------------------------------------------------------------

#' @export
metaData.sf <- function(obj) {
  obj
}

# pointsData --------------------------------------------------------------

#' @export
pointData.sf <- function(obj) {
  geometry <- obj[[attr(obj, "sf_column")]]
  pointData(geometry)
}

#' @export
pointData.sfc_POINT <- function(obj) {
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
    obj <- matrix(obj, nrow = 1)
  }

  structure(
    sf_coords(obj),
    bbox = bbox
  )
}

# polygonData -------------------------------------------------------------

#' @export
polygonData.sf <- function(obj) {
  geometry <- obj[[attr(obj, "sf_column")]]
  polygonData(geometry)
}

#' @export
polygonData.sfc <- function(obj) {
  check_crs(obj)

  structure(
    lapply(obj, to_multipolygon),
    bbox = sf_bbox(obj)
  )
}

#' @export
polygonData.MULTIPOLYGON <- function(obj) {
  structure(
    to_multipolygon(obj) %>%
      list(), # list of multipolygons
    bbox = sf_bbox(obj)
  )
}

#' @export
polygonData.MULTILINESTRING <- polygonData.MULTIPOLYGON

#' @export
polygonData.POLYGON <- function(obj) {
  lapply(obj, sf_coords)
}
#' @export
polygonData.LINESTRING <- function(obj) {
  structure(
    to_polygon(obj) %>%
      list() %>% # multipolygon
      list(),    # list of multipolygons
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
to_polygon.LINESTRING <- function(x) {
  list(sf_coords(x))
}

#' @export
to_polygon.POLYGON <- function(x) {
  lapply(x, sf_coords)
}

#' @export
to_multipolygon.sfc <- function(x) {
  lapply(x, to_polygon)
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
