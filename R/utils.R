# remove NULL elements from a list
filterNULL = function(x) {
  if (length(x) == 0 || !is.list(x)) return(x)
  x[!unlist(lapply(x, is.null))]
}

appendMapData = function(map, data, component, ...) {
  x = map$x$calls
  if (is.null(x)) x = list()
  n = length(x)
  x[[n + 1]] = list(
    method = component,
    args = evalFormula(list(...), data)
  )
  map$x$calls = x
  map
}

# A helper function to generate the body of function(x, y) list(x = x, y = y),
# to save some typing efforts in writing tileOptions(), markerOptions(), ...
makeListFun = function(list) {
  if (is.function(list)) list = formals(list)
  nms = names(list)
  cat(sprintf('list(%s)\n', paste(nms, nms, sep = ' = ', collapse = ', ')))
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}
