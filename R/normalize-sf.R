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
    lapply(obj, polygonData),
    bbox = sf_bbox(obj)
  )
}

#' @export
polygonData.MULTIPOLYGON <- function(obj) {
  # Each element of obj is a polygon (list).
  # Each element of a polygon is a ring (matrix).
  structure(
    lapply(obj, function(polygon) {
      lapply(polygon, function(ring) {
        sf_coords(ring)
      })
    }),
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
polygonData.LINESTRING <- polygonData.POLYGON


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
  structure(
    as.data.frame(x),
    names = c("lng", "lat")
  )
}

sf_bbox <- function(x) {
  matrix(sf::st_bbox(x), ncol = 2, byrow = FALSE)
}
