# metaData ----------------------------------------------------------------

#' @export
metaData.SpatVector <- function(obj) {
  data.frame(obj)
}


#' @export
pointData.SpatVector <- function(obj) {
  check_crs_terra(obj)
  xy = data.frame(terra::crds(obj))
  names(xy) = c("lng", "lat")
  structure(
    xy,
    bbox = terra_bbox(obj)
  )
}


# polygonData -------------------------------------------------------------

#' @export
polygonData.SpatVector <- function(obj) {
  check_crs_terra(obj)

  xy = data.frame(terra::geom(obj))
  names(xy)[3:4] = c("lng", "lat")
  xy = split(xy[,2:5], xy[,1]) # polygons
  names(xy) = NULL  # won't work with names
  xy = lapply(xy, function(p) {
    d = split(p[,-1], p[,1]) # parts
    names(d) = NULL
    lapply(d, function(p) {   # ring and holes
      s = split(p[,1:2], p[,3])
      names(s) = NULL
      lapply(s, function(i) { rownames(i) = NULL; i }) # for expect_maps_equal
    })
  })

  # with terra >= 1.5-50 you can do this instead
  # xy = terra::geom(obj, list=TRUE, xnm="lng", ynm="lat")

  structure(
    xy,
    bbox = terra_bbox(obj)
  )
}



# helpers -----------------------------------------------------------------
assure_crs_terra <- function(x) {
  stopifnot(is_installed("terra"))

  prj <- raster::crs(x, proj = TRUE)

  if (is.na(prj) || (prj == "")) {
    # Don't have enough information to check
    warning("SpatVector layer is not long-lat data", call. = FALSE)
    return(x)
  }

  if (terra::is.lonlat(x, perhaps = TRUE, warn = FALSE)) {
    if (!grepl("+datum=WGS84", prj, fixed = TRUE)) {
      x <- terra::project(x, "+proj=longlat +datum=WGS84")
    }
    return(x)
  }

  terra::project(x, "+proj=longlat +datum=WGS84")
}

check_crs_terra <- function(x) {
  crs <- crs(x)

  # Don't have enough information to check
  if (is.na(crs) || (crs==""))
    return()

  if (identical(terra::is.lonlat(x), FALSE)) {
    warning("SpatVector layer is not long-lat data", call. = FALSE)
  }

  prj <- crs(x, proj=TRUE)
  if (!grepl("+datum=WGS84", prj, fixed = TRUE)) {
    warning(
      "SpatVector layer has inconsistent datum (", prj, ").\n",
      "Need '+proj=longlat +datum=WGS84'",
      call. = FALSE
    )
  }

}


terra_bbox <- function(x) {
  structure(
    matrix(as.vector(terra::ext(x)), ncol = 2, byrow = TRUE),
    dimnames = list(c("lng", "lat"), NULL)
  )
}
