#' @export
doResolveFormula.SharedData <- function(data, f) {
  doResolveFormula(data$data(withSelection = TRUE, withFilter = FALSE, withKey = TRUE), f)
}

#' @export
pointData.SharedData <- function(obj) {
  pointData(obj$data(withSelection = FALSE, withFilter = FALSE, withKey = FALSE))
}

#' @export
polygonData.SharedData <- function(obj) {
  polygonData(obj$data(withSelection = FALSE, withFilter = FALSE, withKey = FALSE))
}
