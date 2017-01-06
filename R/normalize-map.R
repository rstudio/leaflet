#' @export
doResolveFormula.map <- function(data, f) {
  eval(f[[2]], data, environment(f))
}


#' @export
polygonData.map <- function(obj) {
  polygonData(cbind(obj$x, obj$y))
}
