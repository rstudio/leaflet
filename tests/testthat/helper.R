create_square <- function(width = 2, lng = 0, lat = 0, hole = FALSE, type = Polygon) {
  lngs <- c(lng - width / 2, lng + width / 2, lng + width / 2, lng - width / 2)
  lats <- c(lat + width / 2, lat + width / 2, lat - width / 2, lat - width / 2)

  if (hole) {
    lngs <- rev(lngs)
    lats <- rev(lats)
  }

  if ("hole" %in% names(formals(type))) {
    type(cbind(lng = lngs, lat = lats), hole = hole)
  } else {
    type(cbind(lng = lngs, lat = lats))
  }
}


