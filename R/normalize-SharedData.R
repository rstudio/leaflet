#' @import lazyeval
#' @export
find_data.SharedData <- function(obj) {
  lazyeval::find_data(obj$data(withSelection = TRUE, withFilter = FALSE, withKey = TRUE))
}

#' @export
pointData.SharedData <- function(obj) {
  pointData(obj$data(withSelection = FALSE, withFilter = FALSE, withKey = FALSE))
}

#' @export
polygonData.SharedData <- function(obj) {
  polygonData(obj$data(withSelection = FALSE, withFilter = FALSE, withKey = FALSE))
}
