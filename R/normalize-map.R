#' @export
find_data.map <- function(obj) {
  obj
}

#' @export
polygonData.map <- function(obj) {
  polygonData(cbind(obj$x, obj$y))
}
